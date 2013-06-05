world = null
bodies = []
archer = null
cannonSound = new Howl
	urls: ["cannon.mp3"]
cannon = null
balls = []
scale = 28


class Cannon
	constructor: () ->
		@image = document.getElementById "cannon" 

	draw: (canvas) ->
		


class MyWorld
	constructor: (@bodies, @archer, @balls) ->
		@canvas = document.getElementById "gamecanvas"
		@game = @canvas.getContext "2d"
		@arrows = []
		@canvas.onselectstart = () -> false
		@cannon = new Cannon


	draw: () ->

		@drawBackground()

		@drawBall ball for ball in @balls
		@drawWall wall for wall in @bodies
		@drawArcher()
		@drawArrow arrow for arrow in @arrows

		@cannon.draw @game

	drawBall: (ball) ->
		pos = @getPosition ball


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

myworld = null


$ () -> 
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
	bodyDef.position.Set 10, 400 / 30 + 1.8
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

	myworld = new MyWorld bodies, archer, []


update = () ->
	world.Step 1/60, 10, 10
	world.DrawDebugData()
	world.ClearForces()
	myworld.draw()