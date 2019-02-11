from setuptools import setup, find_packages
from os import path
from io import open

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name=".pyenv",
    version="1.2.9",
    description="pyenv lets you easily switch between multiple versions of Python. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.",
    long_description = long_description,
    long_description_content_type = 'text/markdown',
    url = "https://github.com/pyenv/pyenv",
    author = "Yamashita, Yuu",
    author_email = "peek824545201@gmail.com",
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Operating System :: MacOS',
        'Operating System :: POSIX',
        'Operating System :: Unix',
        'Programming Language :: Unix Shell',
        'Topic :: Software Development :: Interpreters',
        'Topic :: System :: Systems Administration',
        'Topic :: Utilities',
    ],
    packages = find_packages(exclude=['tests']),
    package_dir = {'.pyenv': '.pyenv'},
    package_data = {'.pyenv': ['bin/*', 'completions/*', 'libexec/*', 'plugins/*', 'pyenv.d/*', 'src/*']},
)
