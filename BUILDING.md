# Building Poddr

To build Poddr you'll need:
* Yarn
* NodeJS

To get Poddr up and running:

``` 
git clone https://github.com/sn8z/poddr.git
cd poddr
yarn install
yarn start 
```

To build distributables for your currently running OS:

```
yarn run dist
```

To build for a specific OS:
```
yarn run dist:win
yarn run dist:mac
yarn run dist:linux
```

The distributables can be found in the *dist* folder.

## Branches
There will be atleast two different branches available at all times so when you are building Poddr check what branch you're on.

#### master
The master branch reflects the latest release of Poddr. This branch is stable and should be used if you're a person who just wants to use Poddr.

#### dev
The dev branch contains the latest updates & features and is not yet officially released. There are no promises that this branch will work at all times and it should be considered unstable. But if you want to help develop Poddr this is the branch you should take a look at.
