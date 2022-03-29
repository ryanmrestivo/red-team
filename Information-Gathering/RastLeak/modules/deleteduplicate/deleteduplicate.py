#!/usr/bin/env python
def DeleteDuplicate(data):
	urls_union = []
	for i in data:
		if i not in urls_union:
			urls_union.append(i)
	return urls_union