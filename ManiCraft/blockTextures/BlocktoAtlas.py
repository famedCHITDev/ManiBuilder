from PIL import Image
import os
import math

blockList = []

# read file + folder
f = open("blockList.txt")
for i in f.readlines():
	p = i.rstrip('\n')
	blockList.append(p)

for k in os.listdir('textures'):
    if k.endswith('.png') and k not in blockList:
        blockList.append(k)
f.close()

# write file
f = open("blockList.txt","w")
for i in blockList:
	f.write(i)
	f.write("\n")
f.close()

resolution = int(input("What should the atlas's size be? (The atlas is a square, the size is the square root of how many tiles you want in the atlas) "))
if math.pow(resolution,2) < len(blockList):
	resolution = len(blockList)

templFile = "template.png"
with Image.open(templFile) as templ:
	templ.load()
atlas = templ.crop((0,0,resolution*16,resolution*16))

for index, i in enumerate(blockList):
	with Image.open(os.path.join('textures', i)) as img:
		img.load()
	atlas.paste(img, (16*(index%resolution), 16*int((index/resolution))))
	
atlas.show()
atlas.save("blockAtlas.png")

