pragma solidity ^0.8.0;

contract Election{
    
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

    modifier onlyOwner(){
        require(msg.sender == owner, 'No autorizado');
        _;
    }

    modifier onlyWhitelist(){
        require(whiteList[msg.sender], 'No autorizado');
        _;
    }
    
    uint64 votationDelay;
    uint64 numProposals;
	mapping (uint256 => bool) private executed;
    mapping (uint256 => uint256) private dates; 
    mapping (uint256 => Proposal) private proposals;
    mapping (address => bool) private whiteList;
    
    
    //Candidato[] public candidatos
    //MODIFICAR:
    
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

    //Solo se llama una vez
    
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