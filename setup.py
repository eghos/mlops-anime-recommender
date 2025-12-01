from setuptools import setup,find_packages

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    name = "hybrid-anime-recommender",
    version ="0.1",
    authur="anthony",
    packages=find_packages(),
    install_requires = requirements
)