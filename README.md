# edgex-perl-connector
Edge-X S3 Perl Connector library

S3X interface for High-Performance load/unload/edit of billions of images
via object HTTP/S interface.

<p align="center">
  <img src="https://github.com/Nexenta/edgex-perl-connector/raw/master/edgefs-s3x-kv-benefits.png?raw=true" alt="edgefs-s3x-kv-benefits.png"/>
</p>

It is S3 compatible protocol, with extensions that allows batch operations
so that load of hundreds objects (like pictures, logs, packets, etc) can be
combined as one S3 emulated object.

## Configuration

1. Clone Perl connector repository

```
git clone https://github.com/highpeakdata/edgex-perl-connector.git
cd edgex-perl-connector
```

2. Install additonal Perl modules (if needed)

```
cpan Digest::HMAC_SHA1
cpan LWP::Protocol::https
```

3. Setup configuration parameters

edgex-perl-connector gets the following parameters from s3cmd configuration file ~/.s3cfg

```
host_base - s3x host[:port]
use_https - True/False 
access_key - access key for s3 authentication
secret_key - secret key for s3 authentication
```

The local file .s3cfg could be used to override the global parameters from ~/.s3cfg

It is also possible to override individual parameters through environment variables.

## Commands

1. Upload images

```
./put.pl <input dir | input image> <target s3x path> [<content type> [replace]]
```
  
2. List images

```
./list.pl <s3x path>
```

3. Download image

```
./get.pl  <s3x path> <image name>
```
  
4. Delete image

```
./del.pl  <s3x path> <image name>
```
  

## Examples

Insert local files from ./input folder into S3X object bk1/obj1 as one blob object with Key-Value access

```
./put.pl ./input bk1/obj1
inserted 13 blob records into S3X object http://10.3.3.3:3000/bk1/obj1
```

List keys of a given S3X object

```
./list.pl bk1/obj1
1540708437.jpg  2018-10-27 23:34:12     image/jpeg      373116
1540708497.jpg  2018-10-27 23:35:47     image/jpeg      373537
1540708557.jpg  2018-10-27 23:36:10     image/jpeg      373228
1540708617.jpg  2018-10-27 23:37:42     image/jpeg      373597
1540708677.jpg  2018-10-27 23:38:13     image/jpeg      373452
1540708737.jpg  2018-10-27 23:39:42     image/jpeg      373713
1540708797.jpg  2018-10-27 23:40:06     image/jpeg      373194
1540708857.jpg  2018-10-27 23:41:48     image/jpeg      372971
1540708917.jpg  2018-10-27 23:42:11     image/jpeg      373893
1540708977.jpg  2018-10-27 23:43:51     image/jpeg      373629
1540709037.jpg  2018-10-27 23:44:10     image/jpeg      374182
1540709097.jpg  2018-10-27 23:45:42     image/jpeg      373571
1540709157.jpg  2018-10-27 23:46:11     image/jpeg      374894
1540709217.jpg  2018-10-27 23:47:46     image/jpeg      374701
1540709277.jpg  2018-10-27 23:48:08     image/jpeg      374406
1540709337.jpg  2018-10-27 23:49:45     image/jpeg      375400
```

Insert local files one by one into S3X blob object with Key-Value access

```
./put.pl ./input/1540708437.jpg bk1/obj2
./put.pl ./input/1540708497.jpg bk1/obj2
```

List keys of a given S3X object

```
./list.pl bk1/obj2
1540708437.jpg  2018-10-27 23:34:12     image/jpeg      373116
1540708497.jpg  2018-10-27 23:35:47     image/jpeg      373537
```

Download a given key of S3X object as a local file

```
./get.pl bk1/obj1 1540699677.jpg
saved as ./1540699677.jpg
```

Delete a given key of existing S3X object

```
./del.pl bk1/obj1 1540699677.jpg
```
