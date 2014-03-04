<?php
/*

Oxygen Webhelp plugin
Copyright (c) 1998-2013 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * Export data in xml format
 *
 * @author serban
 *
 */
class InLineExporter implements IExporter{
	/**
	 * exported content
	 *
	 * @var String
	 */
	private $toReturn;
	/**
	 * Total exported rows
	 *
	 * @var int
	 */
	private $rows;

	private $ignoredFields;

	private $columnSizes;
	/**
	 * Cell renderer
	 * 
	 * @var ICellRenderer
	 */
	private $cellRenderer;
	/**
	 * Row filter
	 * @var IFilter
	 */
	private $filter;
	private $hasLines;
	private $idField;
	/**
	 * Constructor
	 * 	
	 * @param array $ignoredFields - fields to be ignored in view
	 * @param array $columnSizes - custom column size for each selected field 
	 */
	function __construct($idField,$ignoredFields=null,$columnSizes=null){
		$this->toReturn="";
		$this->idField=$idField;
		$this->rows=0;
		$this->ignoredFields=$ignoredFields;
		$this->columnSizes=$columnSizes;
		$this->hasLines=false;
	}
	
	function setFilter($filter){
		$this->filter=$filter;
	}
		
	/**
	 * Set cell renderer
	 * 
	 * @param ICellRenderer $cellRenderer
	 */
	function setCellRenderer($cellRenderer){
		$this->cellRenderer=$cellRenderer;
	}
	/**
	 * Export one row
	 * @param Array $AssociativeRowArray - array containing fieldName=>fieldValue
	 */
	function exportRow($AssociativeRowArray){
		if (!$this->filter->filter($AssociativeRowArray)){
			$this->hasLines=true;
		$width=20;
		if ($this->rows==0){
			$this->toReturn.="<div class=\"tbHRow\">";
			$column=0;
			foreach ($AssociativeRowArray as $field => $value){
				if (!in_array($field, $this->ignoredFields)){
					if ($this->columnSizes!=null){
						if ($this->columnSizes[$column]){
							$width=$this->columnSizes[$column];
						}else{
							$width=11;
						}
					}
					$this->toReturn.="<div class=\"tbCell\" style=\"width:$width%;\">".Utils::translate("label.tc.".$field)."</div>";
					$column++;
				}
			}
			if ($this->columnSizes!=null){
				$width=$this->columnSizes[count($this->columnSizes)-1];
			}
			//$this->toReturn.="<div class=\"tbCell\" style=\"width:$width%;\"><div>".Utils::translate("selected")."</div></div>";
			$this->toReturn.="</div>";
		}
		$this->rows++;
		$this->toReturn.="<div class=\"tbRow\">";
		$column=0;
		$id=-1;
		foreach ($AssociativeRowArray as $field => $value){
			$this->rows++;
			if ($field==$this->idField){
				$id=$value;
				if ($this->cellRenderer!=null){
				$this->cellRenderer->setAName($id);
			}
			}
			if (!in_array($field, $this->ignoredFields)){
				if ($this->columnSizes!=null){
					if ($this->columnSizes[$column]){
						$width=$this->columnSizes[$column];
					}else{
						$width=11;
					}
				}
				$renderedValue=$value;
				if ($this->cellRenderer!=null){
					$renderedValue=$this->cellRenderer->render($field, $value);
				}
				$this->toReturn.="<div class=\"tbCell\" style=\"width:$width%;\">".$renderedValue."</div>";
				$column++;
			}
		}		
		$this->toReturn.="<div class=\"tbCell\"><input type=\"checkbox\" class=\"cb-element\" value=\"$id\" onclick=\"addToDelete($id);\"/></div>";
		$this->toReturn.="</div>";
		}else{			
			// row filtered
	}
	}

	function getContent(){
		if ($this->hasLines){
			$this->toReturn="<div class=\"table\">".$this->toReturn;
		$this->toReturn.="</div>";
		$this->toReturn.="</div>";
		}
		return  $this->toReturn;
	}
	function getFilter(){
		return $this->filter;
}
}
?>