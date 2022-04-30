pragma solidity ^0.8.0;

contract EternalStorage{
    
    address owner;
    address latestVersion;

    struct Proposal {
		uint id;
        string name;
        string description;
		string[] choices; //Posibles cosas a las que votar
        uint numeroDeOpciones; 
	}
	
    mapping (uint => mapping(uint256 => uint)) votes; //Mapa para registrar votos (indice choices => Nº de votos) || Ejemplo: ( (Chocolate => 3), (Vainilla => 0) )
    mapping (uint => mapping(address => bool)) voted;

    
    mapping(bytes32 => uint) uIntStorage;

    /* uint votationDelay; */
    uint numProposals;
	mapping (uint256 => bool) private executed;
    mapping (uint256 => uint256) private dates; 
    mapping (uint256 => Proposal) private proposals;
    
    
    modifier onlyOwner(){
        require(msg.sender == owner, 'No autorizado');
        _;
    }
    
    modifier onlyLogic(){
        require(msg.sender == latestVersion, 'No autorizado');
        _;
    }
    
    //Candidato[] public candidatos
    //MODIFICAR:
    
    //Solo se llama una vez
    constructor() {
        owner = msg.sender;
        uIntStorage[keccak256(abi.encodePacked("delay"))] = 1;
    }
    
    function upgradeVersion(address _newVersion) public onlyOwner{
        latestVersion = _newVersion;
    }
    
    function getUIntValue(bytes32 record) public onlyLogic view returns (uint){
        return uIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) public onlyLogic
    {
        uIntStorage[record] = value;
    }
    function agregarProposal (string memory _name, string memory _description, string[] memory _choices) public onlyLogic{
        proposals[numProposals++]=Proposal(numProposals, _name, _description, _choices, _choices.length);
        dates[numProposals] = block.timestamp + uIntStorage[keccak256(abi.encodePacked("delay"))];
    }

    function getProposal(uint _numProposals) public onlyLogic view returns (Proposal memory) {
        return proposals[_numProposals];
    }
    
    function getVotes(uint _numProposals, uint _choice) public onlyLogic view returns (uint) {
        return votes[_numProposals][_choice];
    }

    function addVote(uint _numProposals, uint _choice) public onlyLogic{
        votes[_numProposals][_choice]++;
    }
    
    function substractVote(uint _numProposals, uint _choice) public onlyLogic{
        votes[_numProposals][_choice]--;
    }

    function getVoted(uint _numProposals, address user) public onlyLogic view returns (bool) {
        return voted[_numProposals][user];
    }

    function setVoted(uint _numProposals, address user) public onlyLogic{
        voted[_numProposals][user] = true;
    }
    
    function getDate(uint _numProposals) public onlyLogic view returns (uint) {
        return dates[_numProposals];
    }

    function setDate(uint _numProposals, uint date) public onlyLogic{
        dates[_numProposals] = date;
    }

    function setExecuted(uint _numProposals, bool value) public onlyLogic {
        executed[_numProposals] = value;
    }

    function getExecuted(uint _numProposals) public onlyLogic view returns (bool){
        return executed[_numProposals];
    }
}

contract Votation {
    using ballotLib for address;
    address owner;
    address eternalStorage;
    mapping (address => bool) private whiteList;

    modifier onlyOwner(){
        require(msg.sender == owner, 'No autorizado');
        _;
    }

    modifier onlyWhitelist(){
        require(whiteList[msg.sender], 'No autorizado');
        _;
    }
    constructor(address _eternalStorage) {
        eternalStorage = _eternalStorage;
        owner = msg.sender;
    }

    function agregarDirecciones(address _user) public onlyOwner {
        whiteList[_user] = true;
    }
    
    function quitarDirecciones(address _user) public onlyOwner {
        whiteList[_user] = false;
    }
    

    function agregarProposal (string memory _name, string memory _description, string[] memory _choices) public onlyWhitelist{
        eternalStorage.addProposal(_name, _description, _choices);
    }

    function getProposal(uint _numProposals) public onlyWhitelist view returns (string memory, string memory) {
        return (eternalStorage.getProposalName(_numProposals), eternalStorage.getProposalDescription(_numProposals));
    }
    
    function choicesDeProposal(uint _numProposals) public onlyWhitelist view returns (string[] memory) {
        return eternalStorage.getProposalChoices(_numProposals);
    }
    
    function totalVotos(uint _numProposals, uint _choice) public onlyWhitelist view returns (uint) {
        return eternalStorage.getNumberOfVotes(_numProposals, _choice);
    }   
    
    function  votar(uint _numProposals, uint _choice) public onlyWhitelist{
        require(!eternalStorage.getUserHasVoted(_numProposals));
        require(_choice >= 0 && _choice < eternalStorage.getChoicesNumber(_numProposals));
        require(eternalStorage.getDate(_numProposals) < block.timestamp);
        eternalStorage.setUserHasVoted(_numProposals);
        eternalStorage.addVote(_numProposals, _choice);
    }
}

library ballotLib {

    struct Proposal {
		uint id;
        string name;
        string description;
		string[] choices; //Posibles cosas a las que votar
        uint numeroDeOpciones; 
	}

    function getNumberOfVotes(address _eternalStorage, uint _numProposals, uint _choice) public view returns (uint256)  {
        return EternalStorage(_eternalStorage).getVotes(_numProposals, _choice);
    }
    function addVote(address _eternalStorage, uint _numProposals, uint _choice) public {
        EternalStorage(_eternalStorage).addVote(_numProposals, _choice);
    }
    function getUserHasVoted(address _eternalStorage, uint _numProposals) public view returns(bool) {
        return EternalStorage(_eternalStorage).getVoted(_numProposals, msg.sender);
    }
   
    function setUserHasVoted(address _eternalStorage, uint _numProposals) public {
        EternalStorage(_eternalStorage).setVoted(_numProposals, msg.sender);
    }

    function getDate(address _eternalStorage, uint _numProposals) public view returns(uint) {
        return EternalStorage(_eternalStorage).getDate(_numProposals);
    }
     function getChoicesNumber(address _eternalStorage, uint _numProposals) public view returns (uint256)  {
        return EternalStorage(_eternalStorage).getProposal(_numProposals).numeroDeOpciones;
    }  

    function getProposalName(address _eternalStorage, uint _numProposals) public view returns(string memory) {
        return EternalStorage(_eternalStorage).getProposal(_numProposals).name;
    }

    function getProposalChoices(address _eternalStorage, uint _numProposals) public view returns(string[] memory) {
        return EternalStorage(_eternalStorage).getProposal(_numProposals).choices;
    }


    function getProposalDescription(address _eternalStorage, uint _numProposals) public view returns(string memory) {
        return EternalStorage(_eternalStorage).getProposal(_numProposals).description;
    }

    function addProposal(address _eternalStorage, string memory _name, string memory _description, string[] memory _choices) public {
        EternalStorage(_eternalStorage).agregarProposal(_name, _description, _choices);
    }

}