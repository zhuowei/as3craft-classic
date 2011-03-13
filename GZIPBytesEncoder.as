/*
Slightly Modified version of Paul Robertson's GZipEncoder.
The original copyright is below:

For the latest version of this code, visit:
http://probertson.com/projects/gzipencoder/

Copyright (c) 2009 H. Paul Robertson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package 
{
	import flash.errors.IllegalOperationError;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * A class for working with GZIP-encoded data. There are methods for compressing
	 * data to GZIP format data (in a ByteArray). There are also methods for
	 * uncompressing a ByteArray containing GZIP data and accessing it in memory as a ByteArray.
	 *
	 * <p>In order to avoid dependencies on Adobe AIR, this class does not support
	 * the use of File objects for reading directly from or writing directly to
	 * the filesystem. For a version which supports File-related functionality
	 * (and which consequently requires Adobe AIR) see the
	 * GZIPEncoder class.</p>
	 */
	public class GZIPBytesEncoder
	{
	
		
		/**
		 * Uncompresses a GZIP-compressed-format ByteArray to a ByteArray object.
		 *
		 * @param src	The ByteArray object to uncompress. The ByteArray's
		 * 				contents are uncompressed and output as the result. In
		 * 				either case the <code>src</code> object must
		 * 				be compressed using the GZIP file format.
		 *
		 * @returns		A ByteArray containing the uncompressed bytes that were
		 * 				compressed and encoded in the source file or ByteArray.
		 *
		 * @throws ArgumentError	If the <code>src</code> argument is null.
		 *
		 * @throws IllegalOperationError If the specified ByteArray
		 * 								 is not GZIP-format file or data.
		 */
		public function uncompressToByteArray(src:ByteArray):ByteArray
		{
			var gzipData:GZIPFile;
			
			gzipData = parseGZIPData(src);
			
			var data:ByteArray = gzipData.getCompressedData();
			
			try
			{
				data.inflate();
			}
			catch (error:Error)
			{
				throw new IllegalOperationError("The specified source is not a GZIP file format file or data.");
			}
			
			return data;
		}
		
		
		/**
		 * Parses a GZIP-format ByteArray into an object with properties representing the important
		 * characteristics of the GZIP data (the header and footer metadata, as well as the
		 * actual compressed data).
		 *
		 * @param srcBytes	The bytearay of the GZIP data to parse.
		 * @param srcName	The name of the GZIP file.
		 *
		 * @returns		An object containing the information from the source GZIP data.
		 *
		 * @throws ArgumentError	If the <code>srcBytes</code> argument is null
		 *
		 * @throws IllegalOperationError If the specified data is not in GZIP-format.
		 */
		public function parseGZIPData(srcBytes:ByteArray, srcName:String = ""):GZIPFile
		{
			if (srcBytes == null)
			{
				throw new ArgumentError("The srcBytes ByteArray can't be null.");
			}
			
			// For details of gzip format, see IETF RFC 1952:
			// http://www.ietf.org/rfc/rfc1952
			
			// gzip is little-endian
			srcBytes.endian = Endian.LITTLE_ENDIAN;
			
			// 1 byte ID1 -- should be 31/0x1f or else throw an error
			var id1:uint = srcBytes.readUnsignedByte();
			if (id1 != 0x1f)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}
			
			// 1 byte ID2 -- should be 139/0x8b or else throw an error
			var id2:uint = srcBytes.readUnsignedByte();
			if (id2 != 0x8b)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}

			// 1 byte CM -- should be 8 for DEFLATE or else throw an error
			var cm:uint = srcBytes.readUnsignedByte();
			if (cm != 8)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}
			
			// 1 byte FLaGs
			var flags:int = srcBytes.readByte();
			
			// ftext: the file is probably ASCII text
			var hasFtext:Boolean = ((flags >> 7) & 1) == 1;
			
			// fhcrc: a CRC16 for the gzip header is present
			var hasFhcrc:Boolean = ((flags >> 6) & 1) == 1;
			
			// fextra: option extra fields are present
			var hasFextra:Boolean = ((flags >> 5) & 1) == 1;
			
			// fname: an original file name is present, terminated by a zero byte
			var hasFname:Boolean = ((flags >> 4) & 1) == 1;
			
			// fcomment: a zero-terminated file comment (intended for human consumption) is present
			var hasFcomment:Boolean = ((flags >> 3) & 1) == 1;
			
			// must throw an error if any of the remaining bits are non-zero
			var flagsError:Boolean = false;
			flagsError = ((flags >> 2) & 1 == 1) ? true : flagsError;
			flagsError = ((flags >> 1) & 1 == 1) ? true : flagsError;
			flagsError = (flags & 1 == 1) ? true : flagsError;
			if (flagsError)
			{
				throw new IllegalOperationError("The specified data is not in GZIP file format structure.");
			}
			
			// 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
			var mtime:uint = srcBytes.readUnsignedInt();
			
			// 1 byte XFL (flags used by specific compression methods)
			var xfl:uint = srcBytes.readUnsignedByte();
			
			// 1 byte OS
			var os:uint = srcBytes.readUnsignedByte();
			
			// (if FLG.EXTRA is set) 2 bytes XLEN, XLEN bytes of extra field
			if (hasFextra)
			{
				var extra:String = srcBytes.readUTF();
			}
			
			// (if FLG.FNAME is set) original filename, terminated by 0
			var fname:String = null;
	 		if (hasFname)
			{
				var fnameBytes:ByteArray = new ByteArray();
				while (srcBytes.readUnsignedByte() != 0)
				{
					// move position back by 1 to make up for the readUnsignedByte() in the conditional
					srcBytes.position -= 1;
					fnameBytes.writeByte(srcBytes.readByte());
				}
				fnameBytes.position = 0;
				fname = fnameBytes.readUTFBytes(fnameBytes.length);
			}
			
			// (if FLG.FCOMMENT is set) file comment, zero terminated
			var fcomment:String;
	 		if (hasFcomment)
			{
				var fcommentBytes:ByteArray = new ByteArray();
				while (srcBytes.readUnsignedByte() != 0)
				{
					// move position back by 1 to make up for the readUnsignedByte() in the conditional
					srcBytes.position -= 1;
					fcommentBytes.writeByte(srcBytes.readByte());
				}
				fcommentBytes.position = 0;
				fcomment = fcommentBytes.readUTFBytes(fcommentBytes.length);
			}
			
			// (if FLG.FHCRC is set) 2 bytes CRC16
	 		if (hasFhcrc)
			{
				var fhcrc:int = srcBytes.readUnsignedShort();
			}
			
			// Actual compressed data (up to end - 8 bytes)
			var dataSize:int = (srcBytes.length - srcBytes.position) - 8;
			var data:ByteArray = new ByteArray();
			srcBytes.readBytes(data, 0, dataSize);
			
			// 4 bytes CRC32
			var crc32:uint = srcBytes.readUnsignedInt();
			
			// 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
			var isize:uint = srcBytes.readUnsignedInt();
			
			return new GZIPFile(data, isize, new Date(mtime), srcName, fname, fcomment);
		}
	}
}
