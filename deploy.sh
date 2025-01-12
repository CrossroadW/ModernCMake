mkdocs build # 生成site文件夹
git checkout gh-pages 
cp site/* . -r
git checkout master