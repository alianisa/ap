import sys
import os
import codecs

if not os.path.exists('Public'):
    os.makedirs('Public')

if not os.path.exists('External'):
    os.makedirs('External')

allFiles = set()

for root, directories, filenames in os.walk('Sources/'):
    
    count = len(root.split("/")) - 1
    prefix = ""
    if count > 1:
        for i in range(0, count):
            prefix = prefix + "../"

    for filename in filenames:

        # Matching only header files
        if not filename.lower().endswith(".h"):
            continue

        # File logic path like im/actor/core/Messenger.h
        path = os.path.join(root[8:], filename)
        # Full directory of file like im/actor/core
        dirName = os.path.split(os.path.join(root, filename))[0][8:] + '/'
        # Source file full path like Sources/actor/core/Messenger.h
        srcFile = os.path.join(root, filename)
        # Converted File path like Sources2/actor/core/Messenger.h
        destFile = os.path.join('Public', path)
        externalFile = os.path.join('External', path)
        
        allFiles.add(path)
        
        # Auto Create directory
        if not os.path.exists(os.path.dirname(destFile)):
            os.makedirs(os.path.dirname(destFile))
                
        if not os.path.exists(os.path.dirname(externalFile)):
            os.makedirs(os.path.dirname(externalFile))
        
        with codecs.open(srcFile, 'r', encoding='utf-8') as f:
            
            allLines = f.read()
            destLines = ""
            
            with codecs.open(externalFile, 'w', encoding='utf-8') as d:
                d.write(allLines)
            
            for line in allLines.splitlines():
                if (line.startswith("#include") or line.startswith("#import")) and '\"' in line:
                    start = line.index('\"')
                    end = line.index('\"', start + 1)
                    includedFile = line[start + 1:end]
                    if includedFile != 'objc/runtime.h':
                        localIncludePath = os.path.join("Sources/", includedFile)
                        if os.path.exists(localIncludePath):
                            line = line[0:start] + "\"" + prefix + includedFile + "\"" + line[end+1:]
                        else:
                            line = "@import j2objc;"
        
                destLines = destLines + line + "\n"

            isUpdated = True

            if os.path.exists(destFile):
                with codecs.open(destFile, 'rw', encoding='utf-8') as d:
                    if d.read() == destLines:
                        # print "Not Updated"
                        isUpdated = False

            if isUpdated:
                with codecs.open(destFile, 'w', encoding='utf-8') as d:
                    d.write(destLines)

isUmbrellaChanged = True

umbrellaContent = ""
#print "Todos os arquivos"
#print allFiles
for line in allFiles:
    umbrellaContent += "#import \"" + line + "\"\n"

if os.path.exists('Public/ActorCoreUmbrella.h'):
    with codecs.open('Public/ActorCoreUmbrella.h', 'r', encoding='utf-8') as d:
        if d.read() == umbrellaContent:
            isUmbrellaChanged = False

if isUmbrellaChanged:
    with codecs.open('Public/ActorCoreUmbrella.h', 'w', encoding='utf-8') as d:
        d.write(umbrellaContent)

