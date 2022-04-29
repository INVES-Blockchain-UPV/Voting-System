pragma solidity ^0.8.0;

contract EternalStorage{
    
    address owner;

    struct Proposal {
		uint id;
        string name;
        string description;
		string[] choices; //Posibles cosas a las que votar
        uint numeroDeOpciones; 
	}
	
    mapping (uint => mapping(uint256 => uint64)) votes; //Mapa para registrar votos (indice choices => Nº de votos) || Ejemplo: ( (Chocolate => 3), (Vainilla => 0) )
    mapping (uint => mapping(address => bool)) voted;

    
    
    uint64 votationDelay;
    uint64 numProposals;
	mapping (uint256 => bool) executed;
    mapping (uint256 => uint256) dates; 
    mapping (uint256 => Proposal) proposals;
    mapping (address => bool) whiteList;
    
    modifier onlyOwner(){
        require(msg.sender == owner, 'No autorizado');
        _;
    }

    modifier onlyWhitelist(){
        require(whiteList[msg.sender], 'No autorizado');
        _;
    }
    
    //Candidato[] public candidatos
    //MODIFICAR:
    
    //Solo se llama una vez
    constructor() public {
        owner = msg.sender;
        votationDelay = 3600;
    }
    
    function agregarProposal (string memory _name, string memory _description, string[] memory _choices) private onlyWhitelist{
        proposals[numProposals]=Proposal(numProposals, _name, _description, _choices, _choices.length);
        dates[numProposals] = block.timestamp + votationDelay;
		numProposals++;
    }
     
    function agregarDirecciones(address _user) public onlyOwner {
        whiteList[_user] = true;
    }
    
    function quitarDirecciones(address _user) public onlyOwner {
        whiteList[_user] = false;
    }

    
    
    function nombreDeProposal(uint _numProposals) public onlyWhitelist view returns (string memory) {
        return proposals[_numProposals].name;
    }
    
    function choicesDeProposal(uint _numProposals) public onlyWhitelist view returns (string[] memory) {
        return proposals[_numProposals].choices;
    }
    
    function totalVotos(uint _numProposals, uint _choice) public onlyWhitelist view returns (uint64) {
        return votes[_numProposals][_choice];
    }
    
    function  votar(uint _numProposals, uint _choice) public onlyWhitelist{
        
        require(!voted[_numProposals][msg.sender]);
        require(_choice >= 1 && _choice <= proposals[_numProposals].choices.length);
        require(dates[_numProposals] > block.timestamp);
        voted[_numProposals][msg.sender] = true;
        votes[_numProposals][_choice]++;
    }
}


library ballotLib {

    function getNumberOfVotes(address _eternalStorage) public view returns (uint256)  {
        return EternalStorage(_eternalStorage).getUIntValue(keccak256('votes'));
    }

    function getUserHasVoted(address _eternalStorage) public view returns(bool) {
        return EternalStorage(_eternalStorage).getBooleanValue(keccak256(abi.encodePacked("voted",msg.sender)));
    }

    function setUserHasVoted(address _eternalStorage) public {
        EternalStorage(_eternalStorage).setBooleanValue(keccak256(abi.encodePacked("voted",msg.sender)), true);
    }

    function setVoteCount(address _eternalStorage, uint _voteCount) public {
        EternalStorage(_eternalStorage).setUIntValue(keccak256('votes'), _voteCount);
    }
}