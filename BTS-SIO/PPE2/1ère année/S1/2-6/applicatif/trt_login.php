<?php
	if(!empty($_POST['login']) AND !empty($_POST['password'])) {
		$login = $_POST['login'];
		$password = $_POST['password'];
		$con = mysqli_connect("localhost","root","","tp3");
		$req = "SELECT * FROM utilisateurs WHERE login = '$login' AND password = '$password'";
		$res = mysqli_query($con,$req);
		if($ligne = mysqli_fetch_array($res)) {
			session_start();
			$_SESSION['login'] = $login;
			$_SESSION['password'] = $password;
			$_SESSION['test'] = $_ligne['login'];
			mysqli_close($con);
			header("location: mur.php");
		}
		else {
			echo "<p>Identifiant ou mot de passe incorrect</p></br>";
			echo "<a href='login.htm'>Cliquez ici pour vous connecter de nouveau</a>";
		}
	}
	else {
		echo "<p>Les champs sont vides !</p></br>";
		echo "<a href='login.htm'>Cliquez ici pour vous connecter de nouveau</a>";
	}
	mysqli_close($con);
?>
