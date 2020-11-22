// title:  Snake Clone in Wren
// author: Camilo Castro (@clsource)
// desc:   A small snake game clone
// script: wren
// based on: https://github.com/nesbox/TIC-80/wiki/Snake-Clone-tutorial
// repo: github.com/ninjascl/snake

import "random" for Random
var Rand = Random.new()
var T = TIC

class Input {
  static up {T.btn(0)}
		static down {T.btn(1)}
		static left {T.btn(2)}
		static right {T.btn(3)}
		static x {T.btn(5)} 
}

class Color {
  static black {0}
		static white {12}
		static green {5}
		static blue {10}
		static orange {3}
}

class Screen {
  static width {240}
	static height {136}
}

class Entity {
  x {
		  if (!_x) {
				  _x = 0
				}
				
				return _x
		}
		
		x = (value) {
		  _x = value
		}
		
		y {
		  if (!_y) { 
				  _y = 0
				}
				return _y
		}
		
		y = (value) {
		  _y = value
		}
		
		construct new(x,y) {
		  this.x = x
				this.y = y
		}
		
		draw() {}
		update() {}
		collisions() {}
		input() {}

}

class Food is Entity {
  construct new() {
		  place()
		}
		
		random() {
		  x = Rand.int(0, 29)
				y = Rand.int(0, 16)
		}
		
		place() {
        random()
        GameState.game.snake.body.each{|part|
            if (part.x == x && part.y == y) {
                place()
            }
        }
    }
		
		draw() {
		  T.rect(x * 8, y * 8, 8, 8, Color.orange)
		}
		
		collisions() {
		  GameState.game.snake.eat(this)
		}
}

class GUI is Entity {
  construct new() {}
		
		score() {
		  T.print("SCORE %(GameState.score)", 5, 5, Color.blue)
				T.print("SCORE %(GameState.score)", 5, 4, Color.white)
		}
		
		gameover() {
		  T.cls(Color.black)
				T.print("Game Over", (Screen.width/2) - 6 * 4.5, (Screen.height/2), Color.white)
		}
		
		input() {
		  if (!GameState.isPlaying && Input.x) {
				 GameState.start()
				}
		}
		
		draw() {
		  if (GameState.isPlaying) {
				  return score()
				}
				
				gameover()
		}
}

class Stage {
  items {_items}
		
		construct new() {
		 _items = []
		}
		
		add(item) {
			items.add(item)
		}
		
		input() {
		  items.each{|item|
				  item.input()
				}
		}
		
		draw() {
		  items.each{|item|
				  item.draw()
				}
		}
		
		update() {
		  items.each{|item|
				  item.update()
				}
		}
		
		collisions() {
		  items.each{|item|
				  item.collisions()
				}
		}
}

class GameState {
 static game {__game}
	static game = (value) {
	  __game = value
	}
	
	static score {
	 if (!__score) {
		  __score = 0
		}
		return __score
	}
	
	static scoreUp() {
	  __score = score + 100
	}
	
	static frame {
		if (!__frame || __frame > Num.largest -1) {
			__frame = 0
		}
		return __frame
	}
	
	static frameUp() {
	  __frame = frame + 1 
	}
	
	static isTenthFrame {frame % 10 == 0}
 
	static isPlaying {
		if (__isPlaying is Null) {
		  __isPlaying = true
		}
		return __isPlaying
	}
	
	static start() {
	  __isPlaying = true
	}
	
	static gameover() {
	  reset()
			__isPlaying = false
	}
	
	static reset() {
	  __score = 0
			game.reset()
	}
	
}

class Point {
  x {_x}
		y {_y}
		
		construct new(x, y) {
		 _x = x
			_y = y
		}
}

class Direction {
  static up {directions[0]}
		static down {directions[1]}
		static left {directions[2]}
		static right {directions[3]}
		
		static directions {
		  if (!__directions) {
				  __directions = [
						 Point.new(0, -1), // up
							Point.new(0, 1), // down
							Point.new(-1, 0), // left
							Point.new(1,0) // right
						]
				}
				return __directions
		}
}

class Snake is Entity {
  tail {body[0]}
		neck {body[body.count - 2]}
		head {body[body.count - 1]}
		
		body {
		  if (!_body) {
				  var tail = Point.new(15, 8)
						var neck = Point.new(14, 8)
						var head = Point.new(13, 8)
						_body = [tail, neck, head]
				}
				return _body
		}
		
		direction {
		  if (!_direction) {
				 _direction = Direction.up
				}
				return _direction
		}
		
		reset() {
		  _body = null
				_direction = Direction.up
		}
		
		input() {
		  var last = direction
				if (Input.up) {
				  _direction = Direction.up
				}
				
				if (Input.down) {
				  _direction = Direction.down
				}
				
				if (Input.left) {
				  _direction = Direction.left
				}
				
				if (Input.right) {
				  _direction = Direction.right
				}
				
				if (head.x + direction.x == neck.x &&
				    head.y + direction.y == neck.y) {
						_direction = last
				}
		}
		
		draw() {
		
		  body.each{|part|
				  T.rect(part.x * 8, part.y * 8, 8, 8, Color.blue)
				}
		}
		
		update() {
		  var x = (head.x + direction.x) % 30
				if (x < 0) {
				 x = 29
				}
				
				var y = (head.y + direction.y) % 17
				if (y < 0) {
				 y = 17
				}
				
				var part = Point.new(x, y)
				
				body.add(part)
		}
		
		removeTail() {
		  body.removeAt(0)
		}
		
		eat(food) {
		  if (head.x == food.x && head.y == food.y) {
				  T.sfx(0, "C-5", 10)
						GameState.scoreUp()
						food.place()
				} else {
				  removeTail()
				}
		}
		
		collisions() {
		  body[0...(body.count -1)].each{|part|
				 if (head.x == part.x && head.y == part.y) {
					  GameState.gameover()
					}
				}
		}
		
		construct new() {}
}

class Game is TIC {

  stage {
		 if (!_stage) {
			 _stage = Stage.new()
				_stage.add(snake)
				_stage.add(food)
				_stage.add(gui)
			}
			return _stage
		}
		
		snake {
		 if (!_snake) {
			 _snake = Snake.new()
			}
			return _snake
		}
		
		food {
		  if (!_food) {
				  _food = Food.new()
				}
				return _food
		}
		
		gui {
		 if (!_gui) {
			 _gui = GUI.new()
			}
			return _gui
		}
		 
  construct new() {
		  GameState.game = this
		  reset()
		}
		
		TIC() {
		 T.cls(Color.green)
			GameState.frameUp()
			
			input()
			
			if (GameState.isTenthFrame) {
			  update()
			  collisions()
			}
			
			draw()	
		}
		
		reset() {
		  snake.reset()
		}
		
		input() {
		  stage.input()
		}
		
		
		update() {
		  stage.update()
		}
		
		collisions() {
		  stage.collisions()
		}
		
		draw() {
				stage.draw()
		}
		 
}
