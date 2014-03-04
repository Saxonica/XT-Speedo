<?php

if (isset($_GET['file']) && trim($_GET['file'])!=""){
	$file=$_GET['file'].".sql";
	if (file_exists($file)){
		$dbConnectionInfo['dbName']="comments";

		$con = mysql_connect("localhost","syncro","sync");
		if ($con !== false){
			mysql_select_db("comments", $con);
			$f = fopen($file,"r+");
			$sqlFile = fread($f,filesize($file));
			$sqlArray = explode(';',$sqlFile);
			$count=count($sqlArray);
			$i=0;
			$err=0;
			foreach ($sqlArray as $stmt) {
				$i++;
				if ($stmt!=""){
					$result = mysql_query($stmt);
					if (!$result){
						$err++;
						$sqlErrorCode = mysql_errno();
						$sqlErrorText = mysql_error();
						echo "Error for query='$stmt' $i form $count > ".$sqlErrorCode.":".$sqlErrorText;
						$sqlStmt      = $stmt;
					}
				}
			}
		}

		if ($err==0){
			echo "DB ready for tests!";
		}else{
			echo "<br>DB NOT ready for tests!";
		}
	}else{
		echo "File does not exist!";
	}
}else{
	echo "Invalid file! <br/> Usage initDbForTests.php?file=&lt;file without .sql extension&gt;";
}
?>