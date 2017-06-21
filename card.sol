pragma solidity ^0.4.11;

// カードマスター
contract CardMaster {
    // CardのContractのリスト
    mapping(address => Card) private cards;
    // アドレスを管理する配列
    address[] private addressList;

    event Debug(address c);

    /**
     * CardのContractを配列とマップに追加
     */
    function addCard(bytes32 _name, uint _issued) {
        Card c = new Card(_name, _issued, msg.sender);
        addressList.push(address(c));
        cards[address(c)] = c;
        Debug(address(c));
    }
    
    /**
     * カードのアドレスの配列取得
     */
    function getCardAddressList() constant returns (address[] cardAddressList) {
        cardAddressList = addressList;
    }

    /**
     * カードを取得
     */
    function getCard(address cardAddress) constant returns (Card) {
        Card c = cards[cardAddress];
        return c;
    }
}

contract Card {
    // カード属性など
    bytes32 public name;
    address public author;
    uint public issued;
    
    // 誰が何枚持っているか
    mapping(address => uint) public owns;
    // [Tips]動的配列はpublicで参照できない
    address[] private owners;
    
    event Debug(string);
    
    function Card(bytes32 _name, uint _issued, address _author){
        name = _name;
        // author = msg.sender; // カードのコントラクトになってしまう
        author = _author;
        issued = _issued;
        owners.push(author);
        owns[author] = issued;
    }
    
    /**
     * ownerのアドレスの配列取得
     */
    function getOwnerAddressList() constant returns (address[] ownerAddressList) {
        ownerAddressList = owners;
    }
    
    // 売る
    struct SellInfo {
        address from;
        uint quantity;
        uint price; // weiで指定
    }
    
    // 買う
    function buy(address from, address to, uint quantity){
        bool hasOwn = false;
        // 既にオーナーかどうか（もっといい方法ないかな？）
        for(uint i; i < owners.length; i++){
            if(owners[i] == to){
               hasOwn = true;
            }
        }
        if(!hasOwn){
            // 初オーナー
            owners.push(to);
            owns[from] -= quantity;
            owns[to] = quantity;
        }else{
            // 既にオーナー
            owns[from] -= quantity;
            owns[to] += quantity;
        }
    }
   
}

// 買う（オークションのような）
// balanseが必要なのでコントラクトになる
contract Buy {
    address buyer;
    uint quantity;
    
    function Buy(uint _quantity) {
        buyer = msg.sender;
        quantity = _quantity;
    }

}

// 履歴
contract History {
    
    address from;
    address to;
    address card;
    uint32 price;
    uint16 quantity;
    
    function History(
        address _from,
        address _to,
        address _card,
        uint32 _price,
        uint16 _quantity
    ){
        from = _from;
        to = _to;
        card = _card;
        price = _price;
        quantity = _quantity;
    }

}

contract UserMaster {
    mapping (address => User) users;
    function add(){
        User u = new User();
        users[address(u)] = u;
    }
}

// ユーザ
contract User {
    address[] public ownedCard;
    address[] public activity;
    function User(){
    }
}
