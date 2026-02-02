# chess

A simple chess game made with flutter.

This is a simple hobby project of mine,
i wanted to test out if it was actually complex to implement a "Chess engine" from scratch.

At the moment of me writting this. I managed to make a fully working game, You can try it out on your browser [here](https://sylanecpn.github.io/chess/).

Let you want to play chess with your sibling, your friend or your cat and you don't have a physical board to play on (and somehow [chess.com](https://chess.com) is down), you can use the app to play on any device.

## Features

- Smooth move animations
- Smart game state checking (knows checkmate , stalemate and when there is not enough material to win).
- Moves assistance (shows the legal moves available for a given piece)
- Board flipping

### What is missing 

- Online play
- Playing against bots
- Piece and color customisation


## Assets

The piece assets are not mine they have been taken from [greenchess.net](https://greenchess.net/info.php?item=downloads).


## Getting Started

If you want to try the app, you can access the [web version](https://sylanecpn.github.io/chess).

If you want to run the project from the source code, you will need to install the flutter sdk.

Once it's correctly installed you can run it on your system by entering :

```console
flutter run
```
in your terminal.

You can also build an apk (for android) with :

```console
flutter build apk
```

or for the web with
```console
flutter build web --wasm
```



## TODO

- implement draw by repetition
