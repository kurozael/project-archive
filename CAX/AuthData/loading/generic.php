<style>
body
	{
	background: url("<?php echo(htmlspecialchars(base64_decode($_GET["bg"]))) ?>") no-repeat center center fixed; 
	-webkit-background-size: cover;
	-moz-background-size: cover;
	-o-background-size: cover;
	background-size: cover;
}

.center
{
	position: absolute;
	margin: auto;
	top: 0;
	right: 0;
	bottom: 0;
	left: 0;
	width: 500px;
	height: 300px;
}

.bg
{
	position: absolute;
	margin: auto;
	top: 0;
	right: 0;
	bottom: 0;
	left: 0;
	width: 100%;
	height: 300px;
	background: rgba(0, 0, 0, 0.75);
}

.hint
{
	color:white;
	padding:8px;
	font-size:24px;
	text-align:center;
	margin-top:64px;
	font-family: 'Roboto', sans-serif;
	text-shadow: 0px 0px 4px rgba(79, 255, 219, 0.5);
	background: rgba(0, 0, 0, 0.5);
	-webkit-border-radius: 8px;
	-moz-border-radius: 8px;
	border-radius: 8px;
}
</style>

<body onload="Clockwork.OnLoaded()">
	<div class="bg">
	</div>
	
	<div class="center">
		<img width="500px;" height="300px;" src="<?php echo(htmlspecialchars(base64_decode($_GET["logo"]))) ?>"/>
		
		<div class="hint">
			Developed with Clockwork
			<br>
			http://CloudSixteen.com
		</div>
	</div>
</body>