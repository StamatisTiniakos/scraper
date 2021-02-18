# clean environment before build to ensure we don't include redundant modules
rmdir -force -Recurse build -ErrorAction SilentlyContinue
rmdir -force -Recurse *.egg-info -ErrorAction SilentlyContinue
rmdir -force -Recurse dist -ErrorAction SilentlyContinue

# do user install if not run in virtual python env
$userinstall=py -3.8 -c "import sys; print('', end='') if hasattr(sys, 'real_prefix') or hasattr(sys, 'base_prefix') and sys.prefix != sys.base_prefix else print('--user', end='')" 

# install requires
py -3.8 -m pip install $userinstall -r requirements.txt

# compile and build cythonized modules
py -3.8 setup.py build_ext --inplace

# create wheel
py -3.8 setup.py bdist_wheel

cd dist

$file_name = Get-ChildItem

#install wheel
py -3.8 -m pip install --user $file_name.Name
