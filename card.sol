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
    address[] private addressList;

    event Debug(string);
    event Debug_i(uint);
    
    function Card(bytes32 _name, uint _issued, address _author){
        name = _name;
        // author = msg.sender; // カードのコントラクトになってしまう
        author = _author;
        issued = _issued;
        addressList.push(author);
        owns[author] = issued;
    }
    
    /**
     * ownerのアドレスの配列取得
     */
    function getOwnerList() constant returns (address[] ownerAddressList) {
        ownerAddressList = addressList;
    }
    
    // 売る
    struct SellInfo {
        address from;
        uint quantity;
        uint price; // weiで指定
        bool active;
    }
    SellInfo[] public sellInfos;
    
    // Sellデータを作成
    function sell(uint quantity, uint price){
        sellInfos.push(SellInfo(msg.sender, quantity, price, true));
    }
    
    // SellInfosの数を変える
    function sellInfosLength() constant returns (uint){
        return sellInfos.length;
    }
    
    // 買う
    function buy(uint idx) payable {
        
        SellInfo s = sellInfos[idx];
        Debug_i(s.quantity);
        Debug_i(s.price);
        Debug_i(msg.value); // wei

        if(msg.value != s.quantity * s.price){
            throw;
        }

        if(!s.active){
            throw;
        }

        
        address from = s.from;
        address to = msg.sender;
        uint quantity = s.quantity;
        // uint price = s.price;
        
        bool hasOwn = false;
        // 既にオーナーかどうか（もっといい方法ないかな？）
        for(uint i; i < addressList.length; i++){
            if(addressList[i] == to){
               hasOwn = true;
            }
        }
        if(!hasOwn){
            // 初オーナー
            addressList.push(to);
            owns[from] -= quantity;
            owns[to] = quantity;
        }else{
            // 既にオーナー
            owns[from] -= quantity;
            owns[to] += quantity;
        }
        s.active = false;
        s.from.transfer(this.balance);
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
