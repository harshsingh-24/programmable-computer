<h1 align = "center"> 32-bit Processor Design </h1>
<h3 align="center"> CS3L002 - Computer Organization and Architecture </h3>
<h5 align="center"> Project Assignment - <a href="https://www.iitbbs.ac.in/">IIT Bhubaneswar</a> (Autumn 2021) </h5>

<p align="center"> 
<img src="images/full-cpu.jpeg" alt="Final Design of 32-bit CPU" height="600px" width="1000px">
</p>
I have designed and implemented a 32-bit Reduced Instruction Set Computer(RISC) using <a href="http://www.cburch.com/logisim/">LogiSim</a>.

<h2> 🌟 Functionalities </h2>

The processor supports the following Assembly Instructions: - 

<ul>
<li> MOVE Ri, Rj: The content of Rj is transferred to Ri. </li>
<li> MOVE Ri, Immediate (16-bit): The immediate value (32-bit unsigned extended) will be transferred to Ri.</li>
<li> LOAD Ri, X (Rj): The content of memory location [[Rj] + X] is loaded into Ri, where X is a 16-bit unsigned immediate value.</li>
<li> STORE Ri, X (Rj): The content of register Ri is stored in memory [[Rj] + X], where X is a 16-bit unsigned immediate value.</li>
<li> ADD Ri, Rj, Rk:   Ri = Rj + Rk</li>
<li> ADI Ri, Rj, Immediate (16-bit):   Ri = Rj + Immediate Value (32-bit unsigned extended)</li>
<li> SUB Ri, Rj, Rk:  Ri = Rj - Rk</li>
<li> SUI Ri, Rj, Immediate (16-bit):   Ri = Rj - Immediate Value (32-bit unsigned extended)</li>
<li> AND Ri, Rj, Rk:   Ri = Rj AND Rk</li>
<li> ANI Ri, Rj, Immediate (16-bit):   Ri = Rj AND Immediate Value (32-bit unsigned extended)</li>
<li> OR Ri, Rj, Rk:  Ri = Rj OR Rk</li>
<li> ORI Ri, Rj, Immediate (16-bit):  Ri = Rj OR Immediate Value (32-bit unsigned extended)</li>
<li> HLT: Stops the execution</li>
  
</ul>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2> 🤖 Overall Architecture </h2>

<table>
  <tr>
    <th>Units</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>General Purpose Registers</td>
    <td>8 <em>(R0 - R7)</em></td>
  </tr>
  <tr>
    <td>Special Purpose Registers</td>
    <td>7 <em>(PC, IR, RA, RB, RZ, RM, RY)</em></td>
  </tr>
  <tr>
    <td>Address Bit Width</td>
    <td>16</td>
  </tr>
   <tr>
    <td>Data Bit Width</td>
    <td>32</td>
  </tr>
  <tr>
    <td>Random Access Memory(RAM)</td>
    <td>8 MB</td>
  </tr>
  <tr>
    <td>Clock cycles per instruction</td>
    <td>5</td>
  </tr>
  <tr>
    <td>Number of supported instructions</td>
    <td>13</td>
  </tr>
</table>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2> Instruction Encoding </h2>
<ul>
<li>The Encoding format is of 32-bit size (which goes in accordance with the guidelines of RISC - 32 processor).</li><br>
  
  <li>The <b>opcode</b> for any instruction is given by the first five bits of the encoding. (More about opcodes in assembler table section).</li><br>
  
<li>The next five bits after the opcode represents the destination register (Rc), that is in which register you would like to write back your information.</li><br>
  
<li>The next five bits after the destination register signifies the source register - 1 (Ra), that is from which register of the Register file, you want to load your values into Register Ra.</li><br>
  
  <li> <b>( Overlapping ) </b> Depending on the fact that, whether your instruction makes use of immediate value/ offset, the next 16 bits are decided.
<ol>
  <li> <em>Case 1 (When no immediate value or offset is present)</em> :- In this case, the first five bits out of 16 bits, signifies the source register - 2(Rb),  that is from which register of the Register File, you want to load your values into Register Rb. The remaining bits are kept at zero. </li>
  <li> <em>Case 2 (When immediate value or offset is present)</em> :- In this case, the next 16 bits, signifies the immediate value or the offset, needed for the operation.</li><br>
</ol>
  
<li>At last, we have one bit that signifies Enable Immediate or Offset. It means that if any instruction makes use of an offset value or an immediate value, then this bit is set to 1, else it is set to zero (0).</li><br>
  </ol>
  
<p align="center"> 
<img src="images/iencoding.jpeg" alt="Instruction Encoding" height="300px" width="1000px">
</p>

<h2> Register File Encoding </h2>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2> Operation Encoding </h2>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2> Immediate Value Encoding </h2>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)

<h2> Sample Encodings </h2>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png)
