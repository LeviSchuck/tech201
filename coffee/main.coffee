world = null
bodies = []
archer = null
cannonSound = new Howl
	urls: ["cannon.mp3", "cannon.ogg"]
arrowLaunch = new Howl
	urls: ["archer-shoot.mp3","archer-shoot.ogg"]
explosion = new Howl
	urls: ["explosion.mp3", "explosion.ogg"]
arrowLand = [
	new Howl
		urls: ["archer-hit1.mp3", "archer-hit1.ogg"]
	, new Howl
		urls: ["archer-hit2.mp3", "archer-hit2.ogg"]
	]

cannon = null
balls = []
scale = 28
inter = 1 / if $.os.tablet or $.os.phone then 30 else 60


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
		@image2 = document.getElementById "cannon2"
	draw: (badness) ->
		context = myworld.getContext()
		rot = 0
		pos = myworld.getMousePos()
		x = pos.x
		y = pos.y
		y = 600 - y

		hype = Math.sqrt(x*x + y*y)


		rot = Math.asin(y/hype)
		myworld.startRotated @image.width/16, 400-@image.height/2, -rot
		context.globalAlpha = if badness > 0.8 then 0 else 1
		context.drawImage @image, 0, -@image.height/2
		context.globalAlpha = Math.min(badness,1)
		context.drawImage @image2, 0, -@image2.height/2
		myworld.endRotated()


class MyWorld
	constructor: (@bodies, @archer) ->
		@badness = 0
		@indeedWin = false
		@exploded = false
		@lost = 0
		@loseamt = 0
		@level = 1
		if window.location.search.length > 1
			@level = parseInt window.location.search.substring(1)
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
			myworld.shoot()

		), false
		setInterval () -> 
			myworld.makeArrow()
		, 1800
		setInterval () ->
			myworld.didWin()
		, 1000


	draw: () ->
		@badness /= 1.005 if @badness > 0.1 and @badness < 1
		@drawBackground()

		@drawBall ball for ball in @balls
		@drawWall wall for wall in @bodies
		@drawLose()
		@drawArrow arrow for arrow in @arrows
		@drawArcher()
		@cannon.draw @badness

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
		pos = @getPosition arrow
		imageObj = document.getElementById "arrow"
		@startRotated (pos.x) * scale, (pos.y) * scale, arrow.GetAngle()
		@game.drawImage imageObj, -(imageObj.width/2), -(imageObj.height/2)
		@endRotated()

	drawBackground: () ->
		imageObj = document.getElementById "background" 
		pattern = @game.createPattern imageObj, 'repeat' 

		@game.rect 0, 0, @canvas.width, @canvas.height
		@game.fillStyle = pattern
		@game.fill()

	drawLose: () ->
		if @badness < 1 then return
		@game.save()
		@game.globalAlpha = Math.min(@loseamt,1)
		@game.fillStyle = 'black'
		@game.fillRect(0,0,800,800);
		@game.restore()
		@loseamt += inter
		@lost = 2 if @lost < 2
		if @loseamt > 5 and @lost < 3
			@lost = 3
			window.location = "lose.html"

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
	shoot: () ->
		if @badness >= 1 then return
		if @indeedWin then return
		@badness += 0.15
		cannonSound.play()
		pos = @getMousePos()
		x = pos.x + 15
		y = pos.y
		y = @canvas.height - y
		hype = Math.sqrt(x*x + y*y)
		bodyDef = new b2BodyDef
		bodyDef.type = b2Body.b2_dynamicBody
		bodyDef.position.x = (x/hype)*(128/24)
		bodyDef.position.y = 450 / 30 - (y/hype)*(128/24)
		fixDef = new b2FixtureDef
		fixDef.density = 30.0
		fixDef.friction = 0.5
		fixDef.restitution = 0.2
		fixDef.shape = new b2CircleShape 1/3
		ball = world.CreateBody bodyDef
		ball.CreateFixture fixDef
		@balls.push ball
		
		magnitude = 6 + Math.random()
		vec = new b2Vec2 fixDef.density*(x/hype)*magnitude,-fixDef.density*(y/hype)*magnitude
		ball.ApplyImpulse vec, ball.GetPosition()
		if @badness >= 1
			setTimeout (() ->
				explosion.play()
				myworld.exploded = true
				), 800

	makeArrow: () ->
		if Math.abs(@archer.GetAngle()) > 0.3 then return
		if @indeedWin then return
		arrowLaunch.play()
		pos = @getPosition @archer
		bodyDef = new b2BodyDef
		bodyDef.type = b2Body.b2_dynamicBody
		bodyDef.position.x = pos.x - 1.5
		bodyDef.position.y = pos.y
		fixDef = new b2FixtureDef
		fixDef.density = 5.0
		fixDef.friction = 0.75
		fixDef.restitution = 0.45
		fixDef.shape = new b2PolygonShape
		fixDef.shape.SetAsBox 0.25, 0.05
		arrow = world.CreateBody bodyDef
		arrow.CreateFixture fixDef
		@arrows.push arrow
		magnitude = 0.1 + Math.random()*0.03
		pos = myworld.getMousePos()
		x = 200
		y = 300
		hype = Math.sqrt(x*x + y*y)
		vec = new b2Vec2 -fixDef.density*(x/hype)*magnitude,-fixDef.density*(y/hype)*magnitude
		vec2 = arrow.GetPosition()
		vec2.x += (Math.random()-0.5)*0.10
		arrow.ApplyImpulse vec, vec2

		arrow.SetUserData
			didShoot: false
			check: setInterval (() ->
				if Math.abs(arrow.GetAngularVelocity()) < 0.75
					arrowLand[Math.floor(Math.random()*arrowLand.length)].play()
					clearInterval arrow.GetUserData().check
				), 100
	didWin: () ->
		if @indeedWin then return
		if @lost > 1 then return
		offcenter = 0
		for body in @bodies
			if Math.abs(body.GetPosition().x - 18) > 1.4
				offcenter++
		if offcenter > 3
			@indeedWin = true
			setTimeout () ->
				myworld.nextLevel()
			, 2000
	nextLevel: () ->
		if @level >= 4
			window.location = "win.html"
		else
			window.location = "?"+(@level+1).toString()
myworld = null


$ () -> 
	

	world = new b2World new b2Vec2(0,10), true
	fixDef = new b2FixtureDef
	fixDef.density = 16.0;
	fixDef.friction = 0.3;
	fixDef.restitution = 0.06;
	#Create Ground
	bodyDef = new b2BodyDef
	bodyDef.type = b2Body.b2_staticBody
	fixDef.shape = new b2PolygonShape
	fixDef.shape.SetAsBox 20, 2
	bodyDef.position.Set 24, 425 / 30 + 1.8
	world.CreateBody(bodyDef).CreateFixture fixDef
	

	# Create some objects
	bodyDef.type = b2Body.b2_dynamicBody
	i = 0
	top = 0;
	while i < 6
		fixDef.shape = new b2PolygonShape
		height = Math.random()*0.5 + 0.3
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
	fixDef.friction = 0.6;
	bodyDef.position.x = 18
	bodyDef.position.y = -1
	body = world.CreateBody bodyDef
	body.CreateFixture fixDef
	archer = body


	#debugDraw = new b2DebugDraw()
	#debugDraw.SetSprite document.getElementById("canvas").getContext("2d")
	#debugDraw.SetDrawScale 28.0
	#debugDraw.SetFillAlpha 0.3
	#debugDraw.SetLineThickness 1.0
	#debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
	#world.SetDebugDraw debugDraw
	window.setInterval update, inter * 1000

	#canvas = document.getElementById "canvas"
	#canvas.onselectstart = () -> false
	canvas = document.getElementById "gamecanvas"
	canvas.getContext("2d").scale(1024/600, 768/400)

	myworld = new MyWorld bodies, archer


update = () ->
	
	world.Step inter, 10, 10
	#world.DrawDebugData()
	world.ClearForces()
	myworld.draw()
