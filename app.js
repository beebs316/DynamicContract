const http = require('http')
const fs = require('fs')
const Web3 = require('web3')
const port = 5999


const rpcURL = "https://mainnet.infura.io/v3/239ed782a20b46db924fa09058bfc351"
const web3 = new Web3(rpcURL)

const address = '' // Your account address goes here


const server = http.createServer(function(req, res){
    // web3.eth.getBalance(address, (err, wei) => {
    //     balance = web3.utils.fromWei(wei, 'ether')
    //     console.log(balance)
    // })
    // res.write('Test')
    // res.write('joe')
    // res.end()
    res.writeHead(200, { 'Content-Type': 'text/html'})
    fs.readFile('index.html', function(error,data){
        if (error) {
            res.writeHead(404)
            res.write('Error: File Not Found')
        } else {
            res.write(data)
            //web3.eth.getBalance(address, (err, wei) => {
            //    balance = web3.utils.fromWei(wei, 'ether')
                
            //  })
        }
        res.end()
    }) 
})

server.listen(port,function(error) {
    if (error) {
        console.log('SOmething went wrong', error)
    } else {
        
        console.log('Server is listening on port ', + port)
        
    }
})