


#import functions from other script files!
source('import_test.r')
?source
my_test(4,5)


#to see hidden files in a directory:   ls -a


my_test = function(x, y ){
	x**y
}