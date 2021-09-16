package {
	import flash.display.*;
	import flash.geom.Point;
	import flash.events.*;
	import flash.ui.*;

	public class Main1 extends MovieClip {

		var canvas: Graphics;


		var currCoursePer: Number = 0;
		var courses: Array = [];
		var drawLimit: int = 30;
		var colors:Array = [];
		var count: int = 0;
		var totalLength: Number;
		var walls: Array = [];

		var currDot: Dot = null;
		var editMode: Boolean = true;
		var seeCourse: Boolean = true;
		var changeMade: Boolean = true;
		var leftPressed:Boolean = false;
		var rightPressed:Boolean = false;


		var ballStartPoint: Point = new Point(stage.stageWidth / 2, stage.stageHeight / 2) //Point(stage.stageWidth * Math.random(), stage.stageHeight * Math.random());

			public function Main1() {
				// constructor code
				stage.scaleMode = "noScale";
				canvas = this.graphics;
				
				for(var i:int = 0; i < drawLimit; i++)
				{
					colors.push(Math.random() * 0xffffff);
				}
				

				//top left, top right
				addWall(10, 10, stage.stageWidth - 10, 30);
				//top right, bottom right
				addWall(stage.stageWidth - 100, 40, stage.stageWidth - 10, stage.stageHeight - 40);

				//bottom left, bottom right
				addWall(stage.stageWidth-15, stage.stageHeight - 300, 40, stage.stageHeight - 20);
				addWall(200, stage.stageHeight-15, 15, 50);


				mc.x = ballStartPoint.x;
				mc.y = ballStartPoint.y;


				stage.addEventListener(Event.ENTER_FRAME, update);
				stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
				stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}

		private function keyDownHandler(event: KeyboardEvent): void {
			if (event.keyCode == Keyboard.LEFT) {
				leftPressed = true;
			}
			if (event.keyCode == Keyboard.RIGHT) {
				rightPressed = true;
			}
		}

		private function keyUpHandler(event: KeyboardEvent): void {

			if (event.keyCode == Keyboard.LEFT) {
				leftPressed = false;
			}
			if (event.keyCode == Keyboard.RIGHT) {
				rightPressed = false;
			}

			if (event.keyCode == Keyboard.ENTER) {

				editMode = false;
				changeMade = true;
				stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
				stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
		}

		function onUp(e: MouseEvent): void {
			currDot = null;
		}

		function onDown(e: MouseEvent): void {
			var mc: Dot = Dot(e.target);

			if (mc) {
				currDot = mc;
			}

		}

		function calculateWall(point1: Point, point2: Point, wallObj: Object): void {
			//this is the angle of the surface
			var wallAngleInRadians: Number = getAngle(point1, point2);

			var wallLength: Number = getDistance(point1, point2);

			var wallCos: Number = Math.cos(wallAngleInRadians);
			var wallSin: Number = Math.sin(wallAngleInRadians);
			var halfPoint: Point = new Point(point1.x + (wallCos * (wallLength / 2)), point1.y + (wallSin * (wallLength / 2)));

			//this is the perpendicular angle of the surface
			var perpendicularWallAngleRad: Number = wallAngleInRadians + ((Math.PI * 2) / 4);
			var perpendicularCos: Number = Math.cos(perpendicularWallAngleRad);
			var perpendicularSin: Number = Math.sin(perpendicularWallAngleRad);

			wallObj.start = point1;
			wallObj.end = point2;
			wallObj.wallAngleInRadians = wallAngleInRadians;
			wallObj.wallLength = wallLength;
			wallObj.wallSin = wallSin;
			wallObj.wallCos = wallCos;
			wallObj.halfPoint = halfPoint;
			wallObj.perpendicularWallAngleRad = perpendicularWallAngleRad;
			wallObj.perpendicularCos = perpendicularCos;
			wallObj.perpendicularSin = perpendicularSin;
		}


		function addWall(startX: Number, startY: Number, endX: Number, endY: Number): void {
			var point1: Point = new Point(startX, startY);
			var point2: Point = new Point(endX, endY);

			var wallObj: Object = {};
			calculateWall(point1, point2, wallObj);

			walls.push(wallObj);


			var d1: Dot = new Dot();
			stage.addChild(d1);
			d1.x = startX;
			d1.y = startY;

			var d2: Dot = new Dot();
			stage.addChild(d2);
			d2.x = endX;
			d2.y = endY;

			d1.type = "start";
			d2.type = "end";
			d1.wall = wallObj;
			d2.wall = wallObj;

			d1.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			d2.addEventListener(MouseEvent.MOUSE_DOWN, onDown);

		}

		function calculateBall(_initialAngle: Number, ballX: Number, ballY: Number, currWall: Object = null): void {

			var ballPos: Point = new Point(ballX, ballY);
			var ballAngleRad: Number = _initialAngle;
			var ballAngleCos: Number;
			var ballAngleSin: Number;


			ballAngleCos = Math.cos(_initialAngle);
			ballAngleSin = Math.sin(_initialAngle);

			//mc.x = ballX;
			//mc.y = ballY;
			//mc.rotation = radToDegrees(_initialAngle);

			//hit wall position
			var bouncePos: Point;
			var shortestCourse: Number = Number.MAX_VALUE;
			var shortestObj: Object = null;

			//find the wall that the ball is going to hit
			for (var i: int = 0; i < walls.length; i++) {
				var wall: Object = walls[i];

				if (currWall == wall) {
					continue;
				}


				var startAngle: Number = correctAngle(getAngle(ballPos, wall.start));
				var endAngle: Number = correctAngle(getAngle(ballPos, wall.end));


				//trace(startAngle, ballAngleRad, endAngle);

				var len: Number = 2000;
				//just need a really large number to make sure the line is long enough for an intersection
				var destX: Number = (ballAngleCos * len) + ballPos.x;
				var destY: Number = (ballAngleSin * len) + ballPos.y;

				var mockBallEndPoint: Point = new Point(destX, destY);

				bouncePos = intersection(wall.start, wall.end, ballPos, mockBallEndPoint);

				if (bouncePos) {



					var courseLen: Number = getDistance(bouncePos, ballPos);

					if (courseLen < shortestCourse) {
						shortestCourse = courseLen;
						shortestObj = {
							angleRad: ballAngleRad,
							courseLen: courseLen,
							cos: ballAngleCos,
							sin: ballAngleSin,
							start: ballPos,
							end: bouncePos,
							wall: wall
						}
					}
				}
			}

			if (shortestObj) {
				courses.push(shortestObj);

				var wall: Object = shortestObj.wall;
				var perpendicularWallAngleRad: Number = wall.perpendicularWallAngleRad;
				var angleRad: Number = shortestObj.angleRad;

				//this is the new position of the ball
				var newBounceAngle: Number = correctAngle(perpendicularWallAngleRad - (angleRad - perpendicularWallAngleRad) - Math.PI); //- (Math.PI))

				//trace("hit wall", i, "startPos", ballPos, "endPos", bouncePos, "angle", ballAngleRad, "newAngle", newBounceAngle);
				if (count < drawLimit) {
					count++;
					calculateBall(newBounceAngle, shortestObj.end.x, shortestObj.end.y, wall);
				}


			}
		}

		//go over this: https://www.cuemath.com/geometry/intersection-of-two-lines/
		function intersection(p1: Point, p2: Point, p3: Point, p4: Point): Point {

			var x1: Number = p1.x;
			var y1: Number = p1.y;

			var x2: Number = p2.x;
			var y2: Number = p2.y;

			var x3: Number = p3.x;
			var y3: Number = p3.y;

			var x4: Number = p4.x;
			var y4: Number = p4.y;

			var z1: Number = (x1 - x2);
			var z2: Number = (x3 - x4);
			var z3: Number = (y1 - y2);
			var z4: Number = (y3 - y4);
			var d: Number = (z1 * z4) - (z3 * z2);

			// If d is zero, there is no intersection
			if (d == 0) return null;

			// Get the x and y
			var pre: Number = ((x1 * y2) - (y1 * x2))
			var post: Number = ((x3 * y4) - (y3 * x4));
			var _x: Number = ((pre * z2) - (z1 * post)) / d;
			var _y: Number = ((pre * z4) - (z3 * post)) / d;

			// Check if the x and y coordinates are within both lines
			if (_x < Math.min(x1, x2) || _x > Math.max(x1, x2) || _x < Math.min(x3, x4) || _x > Math.max(x3, x4)) {
				return null;
			}

			if (_y < Math.min(y1, y2) || _y > Math.max(y1, y2) || _y < Math.min(y3, y4) || _y > Math.max(y3, y4)) {
				return null;
			}

			// Return the point of intersection
			return new Point(_x, _y);
		}

		function getTotalCourseLength(): Number {
			var len: Number = 0;
			var c: Object;
			for (var i: int = 0; i < courses.length; i++) {
				c = courses[i];
				len += c.courseLen;
			}

			for (i = 0; i < courses.length; i++) {
				c = courses[i];
				var courseLen: Number = c.courseLen;
				var per: Number = courseLen / len;
				var startPer: Number = 0;
				if (courses[i - 1]) {
					startPer = courses[i - 1].endPer;
				}
				var endPer: Number = startPer + per;
				c.startPer = startPer;
				c.endPer = endPer;

			}

			return len;
		}

		/////////

		function drawWall(): void {
			canvas.lineStyle(4, 0);
			for (var i: int = 0; i < walls.length; i++) {
				var wallObj: Object = walls[i];
				var halfPoint: Point = wallObj.halfPoint;
				var perpendicularWallAngleRad: Number = wallObj.perpendicularWallAngleRad;
				var start: Point = wallObj.start;
				var end: Point = wallObj.end;
				var perpendicularCos: Number = wallObj.perpendicularCos;
				var perpendicularSin: Number = wallObj.perpendicularSin;
				var wallLength: Number = wallObj.wallLength;

				canvas.moveTo(start.x, start.y);
				canvas.lineTo(end.x, end.y);
				canvas.moveTo(start.x, start.y);
				canvas.moveTo(halfPoint.x, halfPoint.y);
				canvas.lineTo(halfPoint.x + (perpendicularCos * 10), halfPoint.y + (perpendicularSin * 10));
			}




			//trace(correctAngle(radToDegrees(rad_slopeStartToEnd)), correctAngle(radToDegrees(perpendicularRad)));
		}

		function drawColissionCourse(): void {
			canvas.moveTo(ballStartPoint.x, ballStartPoint.y);
			

			for (var i: int = 0; i < courses.length; i++) {

				var c: Object = courses[i];
				canvas.lineStyle(2, colors[i]);
				canvas.moveTo(c.start.x, c.start.y);
				canvas.lineTo(c.end.x, c.end.y);
			}
			//

		}


		function drawBall(): void {

			var totalCoursePercent: Number = currCoursePer / 100;



			for (var i: int = 0; i < courses.length; i++) {
				var c: Object = courses[i];

				if (totalCoursePercent >= c.startPer && totalCoursePercent <= c.endPer) {
					//trace(totalCoursePercent, i);

					var perSpan: Number = c.endPer - c.startPer;
					var currPer: Number = totalCoursePercent - c.startPer;
					var placementPer: Number = currPer / perSpan;

					//we are here in the course
					var ballPosX: Number = c.start.x + c.cos * c.courseLen * placementPer;
					var ballPosY: Number = c.start.y + c.sin * c.courseLen * placementPer;

					//trace(c.start.x, c.cos, c.courseLen, currCoursePer);
					canvas.drawCircle(ballPosX, ballPosY, 10);
					break;
				}
			}

			currCoursePer += 0.5;
		}

		function update(e: Event = null): void {

			canvas.clear();


			if (editMode) {

				if (currDot) {
					currDot.x = stage.mouseX;
					currDot.y = stage.mouseY;

					//type, wall
					//
					var wallObj: Object = currDot.wall;
					if (currDot.type == "start") {
						calculateWall(new Point(currDot.x, currDot.y), wallObj.end, wallObj)
					} else {
						calculateWall(wallObj.start, new Point(currDot.x, currDot.y), wallObj)
					}
					changeMade = true;

				}
				
				if(leftPressed)
				{
					mc.rotation--;
					changeMade = true;
				}
				
				if(rightPressed)
				{
					mc.rotation++;
					changeMade = true;
				}
				drawWall();

				////do ball stuff
				if (changeMade) {
					courses = [];
					count = 0;
					calculateBall(correctAngle(degreesToRad(mc.rotation)), ballStartPoint.x, ballStartPoint.y);
					totalLength = getTotalCourseLength();
					changeMade = false;
				}


				///

				if (seeCourse) {
					drawColissionCourse();
				}


				return;
			}

			if (seeCourse) {
				drawColissionCourse();
			}

			drawWall();


			drawBall();
			//stage.removeEventListener(Event.ENTER_FRAME, update);

		}



		function correctAngle(_angleRad: Number): Number {
			var PI2: Number = Math.PI * 2;
			while (_angleRad < 0) {
				_angleRad += PI2;
			}

			while (_angleRad > PI2) {
				_angleRad -= PI2;
			}

			return _angleRad;
		}



		function radToDegrees(rads: Number): Number {
			return rads * 180 / Math.PI;
		}

		function degreesToRad(degs: Number): Number {
			return degs * Math.PI / 180;
		}


		function getAngle(from: Point, to: Point): Number {
			var angle: Number = Math.atan2(to.y - from.y, to.x - from.x);
			return angle;
		}

		function getDistance(p1: Point, p2: Point): Number {

			var dX: Number = p1.x - p2.x;
			var dY: Number = p1.y - p2.y;
			var dist: Number = Math.sqrt(dX * dX + dY * dY);
			return dist;
		}

		function angleInRange(angle: Number, left: Number, right: Number): Boolean {
			var PI2: Number = Math.PI * 2;
			if (right < left) {
				if (angle >= left && left <= PI2) {
					return true;
				}
				if (angle < PI2 && angle >= 0 && angle <= right) {
					return true;
				}
			} else {
				if (angle >= left && angle <= right) {
					return true;
				}
			}
			return false;
		}

	}

}