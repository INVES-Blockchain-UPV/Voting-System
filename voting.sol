pragma solidity ^0.4.0;

contract Election{
    
    address owner;

    struct Candidato {
		uint id;
		string nombre;
		uint votos;
	}
	
	uint private numeroCandidatos;
	
    modifier onlyOwner(){
        require(msg.sender == owner, 'no autorizado');
        _;
    }
	mapping (address => bool) private yaVoto;
    mapping (uint => Candidato) private candidatos;
    mapping (address => bool) private direccionesValidas;
    
    //Candidato[] public candidatos

    event Votacion(address author, string candidato);
    
    function agregarCandidato (uint id, string nombre) private {
        candidatos[id]=Candidato(id,nombre,0);
		numeroCandidatos++;
    }
     
    function agregarDirecciones(address user) public onlyOwner {
        direccionesValidas[user] = true;
        /* direccionesValidas[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c] = true;
        direccionesValidas[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db] = true; */
    }
    
    function quitarDirecciones(address user) public onlyOwner {
        direccionesValidas[user] = false;
        /* direccionesValidas[0x14723a09acff6d2a60dcdf7aa4aff308fddc160c] = true;
        direccionesValidas[0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db] = true; */
    }
  
    //Solo se llama una vez
    constructor() public {
        owner = msg.sender;
        agregarCandidato(1, "Juan");
        agregarCandidato(2, "Maria");
        agregarCandidato(3, "Jorge");
        //agregarDirecciones();
    }
    
    function nombreDeCandidato(uint candidatoID) public view returns (string) {
        return candidatos[candidatoID].nombre;
    }
    
    function totalVotos(uint candidatoID) public view returns (uint) {
        return candidatos[candidatoID].votos;
    }
    
    function  votar(uint candidatoID) public {
        
        require(!yaVoto[msg.sender]);
        require(direccionesValidas[msg.sender]);
        require(candidatoID >= 1 && candidatoID <= 3);
        
        yaVoto[msg.sender] = true;
        candidatos[candidatoID].votos++;
        emit Votacion(msg.sender, candidatos[candidatoID].nombre);
    }
}