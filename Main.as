package {
	import flash.display.*;
	import flash.geom.Point;

	public class Main extends MovieClip {
		var point1: Point;
		var point2: Point;

		public function Main() {
			// constructor code

			point1 = new Point(stage.stageWidth * Math.random(), stage.stageHeight * Math.random());
			point2 = new Point(stage.stageWidth * Math.random(), stage.stageHeight * Math.random());

			var canvas: Graphics = this.graphics;


			canvas.lineStyle(1, 0);
			canvas.moveTo(point1.x, point1.y);
			canvas.lineTo(point2.x, point2.y);

			//this is the angle of the surface
			var rad_slopeStartToEnd: Number = getAngle(point1, point2);

			var distance: Number = getDistance(point1, point2);

			var COS: Number = Math.cos(rad_slopeStartToEnd);
			var SIN: Number = Math.sin(rad_slopeStartToEnd);

			canvas.moveTo(point1.x, point1.y);

			var halfPoint: Point = new Point(point1.x + (COS * (distance / 2)), point1.y + (SIN * (distance / 2)))

			canvas.moveTo(halfPoint.x, halfPoint.y);

			//this is the perpendicular angle of the surface
			var perpendicularRad: Number = rad_slopeStartToEnd + ((Math.PI * 2) / 4);

			COS = Math.cos(perpendicularRad);
			SIN = Math.sin(perpendicularRad);

			canvas.lineTo(halfPoint.x + (COS * (distance / 4)), halfPoint.y + (SIN * (distance / 4)));


			trace(correctAngle(radToDegrees(rad_slopeStartToEnd)), correctAngle(radToDegrees(perpendicularRad)));
			
			var ballStartPoint:Point = new Point(0,0);			
			
			canvas.moveTo(ballStartPoint.x,ballStartPoint.y);
			canvas.lineStyle(1,0xff4466);
			canvas.lineTo(halfPoint.x, halfPoint.y);
			
			
			var ballAngle_rad: Number = getAngle(halfPoint, ballStartPoint);
			trace(correctAngle(radToDegrees(ballAngle_rad)));
			
			var bounceAngle:Number = perpendicularRad - (ballAngle_rad - perpendicularRad);
			trace(correctAngle(radToDegrees(bounceAngle)));
			
			COS = Math.cos(bounceAngle);
			SIN = Math.sin(bounceAngle);
			
			canvas.lineTo(halfPoint.x + (COS * (distance / 4)), halfPoint.y + (SIN * (distance / 4)));
			
			
		}

		function correctAngle(_angleDeg: Number): Number {
			while (_angleDeg < 0) {
				_angleDeg += 360;
			}

			while (_angleDeg > 360) {
				_angleDeg -= 360;
			}

			return _angleDeg;
		}



		function radToDegrees(rads: Number): Number {
			return rads * 180 / Math.PI
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

	}

}