<link href='https://fonts.googleapis.com/css?family=Roboto:500' rel='stylesheet' type='text/css'>

<style>
body
{
	background-color:black;
    background-image: url("bg.png");
    background-repeat: repeat;
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

.hint
{
	color:white;
	font-size:24px;
	text-align:center;
	margin-top:64px;
	font-family: 'Roboto', sans-serif;
	text-shadow: 0px 0px 4px rgba(79, 255, 219, 0.5);
}
</style>

<body onload="Clockwork.OnLoaded()">
	<div class="center">
		<img src="clockwork.png"/>
		
		<div class="hint">
		<?php
			$messages = array('Buy Clockwork gamemodes at http://CloudSixteen.com', 'Join the Clockwork community at http://forums.CloudSixteen.com', 'Clockwork was created by kurozael and is maintained by Cloud Sixteen.');
			$key = array_rand($messages);
			
			echo($messages[$key]);
		?>
		</div>
	</div>
</body>