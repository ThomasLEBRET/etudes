<?php

require_once("class/datas/Database.php");

class Animation extends Database {
  private $codeanim;
  private $codetypeanim;
  private $nomanim;
  private $datecreationanim;
  private $datevaliditeanim;
  private $dureeanim;
  private $limiteage;
  private $tarifanim;
  private $nbreplaceanim;
  private $descriptanim;
  private $commentanim;
  private $difficulteanim;


  public function getCodeanim(){
    return $this->codeanim;
  }

  public function setCodeanim($codeanim){
    $this->codeanim = $codeanim;
  }

  public function getCodetypeanim(){
    return $this->codetypeanim;
  }

  public function setCodetypeanim($codetypeanim){
    $this->codetypeanim = $codetypeanim;
  }

  public function getNomanim(){
    return $this->nomanim;
  }

  public function setNomanim($nomanim){
    $this->nomanim = $nomanim;
  }

  public function getDatecreationanim(){
    return $this->datecreationanim;
  }

  public function setDatecreationanim($datecreationanim){
    $this->datecreationanim = $datecreationanim;
  }

  public function getDatevaliditeanim(){
    return $this->datevaliditeanim;
  }

  public function setDatevaliditeanim($datevaliditeanim){
    $this->datevaliditeanim = $datevaliditeanim;
  }

  public function getDureeanim(){
    return $this->dureeanim;
  }

  public function setDureeanim($dureeanim){
    $this->dureeanim = $dureeanim;
  }

  public function getLimiteage(){
    return $this->limiteage;
  }

  public function setLimiteage($limiteage){
    $this->limiteage = $limiteage;
  }

  public function getTarifanim(){
    return $this->tarifanim;
  }

  public function setTarifanim($tarifanim){
    $this->tarifanim = $tarifanim;
  }

  public function getNbreplaceanim(){
    return $this->nbreplaceanim;
  }

  public function setNbreplaceanim($nbreplaceanim){
    $this->nbreplaceanim = $nbreplaceanim;
  }

  public function getDescriptanim(){
    return $this->descriptanim;
  }

  public function setDescriptanim($descriptanim){
    $this->descriptanim = $descriptanim;
  }

  public function getCommentanim(){
    return $this->commentanim;
  }

  public function setCommentanim($commentanim){
    $this->commentanim = $commentanim;
  }

  public function getDifficulteanim(){
    return $this->difficulteanim;
  }

  public function setDifficulteanim($difficulteanim){
    $this->difficulteanim = $difficulteanim;
  }

  public function buildObject(array $datas) {
    foreach($datas as $key => $ligne) {
      $method = 'set'.ucfirst($key);
      if(method_exists($this, $method)) {
        $this->$method($ligne);
      }
    }
  }

  public function getAnimationsValides() {
    $req = "
    SELECT AN.*
    FROM ANIMATION AN, ACTIVITE A
    WHERE AN.CODEANIM = A.CODEANIM
    AND AN.DATEVALIDITEANIM > DATE(NOW())";
    $res = $this->createQuery($req);
    return $res;
  }

}
