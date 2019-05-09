# edgex-perl-connector
Edge-X S3 Perl Connector library

## Examples

Insert local files into S3X as one blob object with Key-Value access

```
./put.pl ./input http://10.3.3.3:3000/bk1/obj1
inserted 13 blob records into S3X object http://10.3.3.3:3000/bk1/obj1
```

List keys of a given S3X object

```
./list.pl http://10.3.3.3:3000/bk1/obj1
1540699257.jpg
1540699317.jpg
1540699377.jpg
1540699437.jpg
1540699497.jpg
1540699557.jpg
1540699617.jpg
1540699677.jpg
1540699797.jpg
1540699857.jpg
1540699917.jpg
1540699977.jpg
1540700037.jpg
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
