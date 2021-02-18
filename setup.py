from setuptools import setup
from Cython.Build import cythonize
from bnbscraper import AUTHOR, AUTHOR_EMAIL, VERSION

with open('requirements.txt') as f:
    requires = tuple(l[:-1] for l in f)

setup(
    name='bnbscraper',
    version=VERSION,
    install_requires=requires,
    author=AUTHOR,
    author_email=AUTHOR_EMAIL,
    description='Bnbscraper',
    ext_modules=cythonize(['bnbscraper/BnbScraper.pyx'],
                          compiler_directives={'linetrace': True}),
    packages=(
        'bnbscraper',
    ),
    exclude_package_data={'': ['*.c', '*.pyx']},
)
