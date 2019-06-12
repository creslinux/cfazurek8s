from setuptools import setup

setup(
    name='cap_demo_app',
    packages=['cap_demo_app'],
    include_package_data=True,
    install_requires=[
        'flask',
    ],
    setup_requires=[
        'pytest-runner',
    ],
    tests_require=[
        'pytest',
    ],
)