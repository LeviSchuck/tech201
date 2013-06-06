world = null
bodies = []
archer = null
cannonSound = new Howl
	urls: ["cannon.mp3"]
cannon = null
balls = []
scale = 28


b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2World = Box2D.Dynamics.b2World
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw
b2MouseJointDef =  Box2D.Dynamics.Joints.b2MouseJointDef

class Cannon
	constructor: () ->
		@image = document.getElementById "cannon" 
	draw: () ->
		context = myworld.getContext()
		rot = 0
		pos = myworld.getMousePos()
		x = pos.x
		y = pos.y
		y = context.canvas.height - y

		hype = Math.sqrt(x*x + y*y)


		rot = Math.asin(y/hype)
		myworld.startRotated @image.width/16, context.canvas.height-@image.height/2, -rot
		context.drawImage @image, 0, -@image.height/2
		myworld.endRotated()


class MyWorld
	constructor: (@bodies, @archer) ->
		@canvas = document.getElementById "gamecanvas"
		canvas = @canvas
		@game = @canvas.getContext "2d"
		@arrows = []
		@canvas.onselectstart = () -> false
		@cannon = new Cannon
		@balls = []
		@mouse = 
			x: 0
			y: 0
		console.log @mouse
		game  = @game
		that = this
		canvas = @canvas
		@canvas.addEventListener "mousemove", ((evt) ->
			rect = canvas.getBoundingClientRect()

			apos =
				x: evt.clientX - rect.left
				y: evt.clientY - rect.top
			if apos.x == 0 or apos.y == 0 then return
			that.mouse.x = (that.mouse.x * 5 + apos.x)/6
			that.mouse.y = (that.mouse.y * 5 + apos.y)/6
			return
		), false
		@canvas.addEventListener "click", ((evt) ->
			cannonSound.play()
			pos = myworld.getMousePos()
			x = pos.x
			y = pos.y
			y = canvas.height - y
			hype = Math.sqrt(x*x + y*y)
			console.log "clicked"
			bodyDef = new b2BodyDef
			bodyDef.type = b2Body.b2_dynamicBody
			bodyDef.position.x = (x/hype)*(128/28)
			bodyDef.position.y = 400 / 30 - (y/hype)*(128/28)
			fixDef = new b2FixtureDef
			fixDef.density = 30.0
			fixDef.friction = 0.5
			fixDef.restitution = 0.2
			fixDef.shape = new b2CircleShape 1/3
			ball = world.CreateBody bodyDef
			ball.CreateFixture fixDef
			that.balls.push ball
			
			magnitude = 6 + Math.random()
			vec = new b2Vec2 fixDef.density*(x/hype)*magnitude,-fixDef.density*(y/hype)*magnitude
			ball.ApplyImpulse vec, ball.GetPosition()

		), false


	draw: () ->

		@drawBackground()

		@drawBall ball for ball in @balls
		@drawWall wall for wall in @bodies
		@drawArcher()
		@drawArrow arrow for arrow in @arrows

		@cannon.draw()

	drawBall: (ball) ->
		pos = @getPosition ball
		imageObj = document.getElementById "ball" 
		x = pos.x*scale - imageObj.width/2
		y = pos.y*scale - imageObj.height/2
		@game.drawImage imageObj, x, y


	drawWall: (wall) ->
		pos = @getPosition wall
		size = wall.m_userData;

		imageObj = document.getElementById "wall" 
		pattern = @game.createPattern imageObj, 'repeat' 
		rect = {}
		rect.x = (pos.x) * scale
		rect.y = (pos.y) * scale
		rect.width = (size.width) * scale * 2
		rect.height = (size.height) * scale * 2
		@startRotated rect.x, rect.y, wall.GetAngle()
		@game.beginPath()
		@game.rect -(rect.width/2), -(rect.height/2), rect.width, rect.height
		@game.fillStyle = pattern
		@game.fill()
		@game.lineWidth = 1;
		@game.strokeStyle = 'black'
		@game.stroke()
		@endRotated()


	drawArcher: () ->
		pos = @getPosition @archer
		imageObj = document.getElementById "archer"
		@startRotated (pos.x) * scale, (pos.y) * scale, archer.GetAngle()
		@game.drawImage imageObj, -(imageObj.width/2), -(imageObj.height/2)
		@endRotated()

	drawArrow: (arrow) ->

	drawBackground: () ->
		imageObj = document.getElementById "background" 
		pattern = @game.createPattern imageObj, 'repeat' 

		@game.rect 0, 0, @canvas.width, @canvas.height
		@game.fillStyle = pattern
		@game.fill()


	getPosition: (body) ->
		body.m_xf.position

	startRotated: (x, y, angle) ->
		@game.save()
		@game.translate x, y
		@game.rotate angle

	endRotated: () ->
		@game.restore()
	getMousePos: () ->
		#console.log @mouse
		@mouse
	getContext: () ->
		@game


myworld = null


$ () -> 
	

	world = new b2World new b2Vec2(0,10), true
	fixDef = new b2FixtureDef
	fixDef.density = 4.0;
	fixDef.friction = 0.5;
	fixDef.restitution = 0.2;
	#Create Ground
	bodyDef = new b2BodyDef
	bodyDef.type = b2Body.b2_staticBody
	fixDef.shape = new b2PolygonShape
	fixDef.shape.SetAsBox 20, 2
	bodyDef.position.Set 24, 400 / 30 + 1.8
	world.CreateBody(bodyDef).CreateFixture fixDef
	

	# Create some objects
	bodyDef.type = b2Body.b2_dynamicBody
	i = 0
	top = 0;
	while i < 6
		fixDef.shape = new b2PolygonShape
		height = Math.random() + 0.1
		width = height * 2
		fixDef.shape.SetAsBox width, height
		bodyDef.position.x = 18
		bodyDef.position.y = top
		top += height*2
		body = world.CreateBody bodyDef
		body.CreateFixture fixDef
		body.m_userData = {}
		body.m_userData.width = width
		body.m_userData.height = height
		body.m_userData.type = "wall"
		bodies.push body

		++i
	#Make the archer
	fixDef.shape = new b2PolygonShape
	fixDef.shape.SetAsBox 1, 1
	bodyDef.position.x = 18
	bodyDef.position.y = -1
	body = world.CreateBody bodyDef
	body.CreateFixture fixDef
	archer = body


	debugDraw = new b2DebugDraw()
	debugDraw.SetSprite document.getElementById("canvas").getContext("2d")
	debugDraw.SetDrawScale 28.0
	debugDraw.SetFillAlpha 0.3
	debugDraw.SetLineThickness 1.0
	debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
	world.SetDebugDraw debugDraw
	window.setInterval update, 1000 / 60

	canvas = document.getElementById "canvas"
	canvas.onselectstart = () -> false

	myworld = new MyWorld bodies, archer


update = () ->
	world.Step 1/60, 10, 10
	world.DrawDebugData()
	world.ClearForces()
	myworld.draw()