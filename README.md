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

## Examples

Insert local files into S3X as one blob object with Key-Value access

```
./put.pl ./input http://10.3.3.3:3000/bk1/obj1
inserted 13 blob records into S3X object http://10.3.3.3:3000/bk1/obj1
```

List keys of a given S3X object

```
./list.pl http://10.3.3.3:3000/bk1/obj1
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

Download a given key of S3X object as a local file

```
./get.pl http://10.3.3.3:3000/bk1/obj1 1540699677.jpg
saved as ./1540699677.jpg
```

Delete a given key of existing S3X object

```
./del.pl http://10.3.3.3:3000/bk1/obj1 1540699677.jpg
```
