# dependencies
express = require('express');
routes = require('./../routes/lib/home');
mongoose = require('mongoose');
mongo = require('mongodb');
passport = require('./authentication');
mongoStore = require('connect-mongo')(express);
moment = require('moment');

app = module.exports = express();
global.app = app;

# configuration file
config = require('./config.js');
app.locals.config = config;

# connect to the database
DB = require('./database');
db = new DB.startup('mongodb://localhost/'+config.dbname);

# sessions
storeConf = {
	db: {db: config.dbname,host: 'localhost'},
	secret: config.sessionSecret
};

# import navigation links
app.locals.links = require('./navigation');

# date manipulation tool
app.locals.moment = moment;

# app config
app.configure () ->
	app.set('views', __dirname + '/../views');
	app.set('view engine', 'jade');
	# highlights top level path
	app.use (req, res, next) ->
		current = req.path.split('/');
		res.locals.current = '/' + current[1];
		res.locals.url = 'http://' + req.get('host') + req.url;
		next();
		return

	app.use(express.bodyParser());
	app.use(express.cookieParser());
	app.use(express.methodOverride());
	app.use(express.session({
		secret: storeConf.secret,
		maxAge: new Date(Date.now() + 3600000),
		store: new mongoStore(storeConf.db)
	}));
	app.use(passport.initialize());
	app.use(passport.session());
	app.use(app.router);
	app.use(express.static(__dirname + './../public'));
	return


# environment specific config
app.configure 'development', () ->
	app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
	return


app.configure 'production', () ->
	app.use(express.errorHandler());
	return


#### load the router ####
passport = require('passport');
home = require('./../routes/lib/home');

# check to see if user is logged in
restrict = (req, res, next) ->
	if (req.user)
		next();
	else
		res.redirect('/login');
	return

# checks if user is an admin
isAdmin = (req, res, next) ->
	if (req.user.role == 'admin')
		next();
	else
		res.redirect('/');
	return

# routes
module.exports = (app) ->
	app.get('/', home.index);
	app.get('/login', home.login);
	app.post '/login', 
	passport.authenticate 'local', 
	{failureRedirect: '/login'}, 
	(req, res) ->
		res.redirect('/')
		return
	app.get('/logout', restrict, home.logout);
	app.get('/about', home.about);
	app.get('/about/tos', home.tos);
	app.get('/register', home.getRegister);
	app.post('/register', home.postRegister);
	app.get('/checkExists', home.checkExists);
	app.get('/profile', restrict, home.profile);
	return

#### end router ####

port = config.port;
app.listen port, () ->
	console.log("Listening on " + port);
	return
