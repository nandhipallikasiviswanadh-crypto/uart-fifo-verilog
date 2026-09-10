# UART FIFO Communication System in Verilog

A Verilog-based UART communication system integrated with a FIFO memory.  
The project demonstrates UART transmission, UART reception, FIFO buffering, and FSM-based control.

## Project Overview

This project combines:

- FIFO Memory
- UART Transmitter
- UART Receiver
- FSM Controller

The FIFO stores incoming data and the controller sends the stored data through the UART transmitter. The UART receiver receives the transmitted data and verifies the communication.

## System Specifications

| Parameter | Value |
|---|---|
| Clock Frequency | 50 MHz |
| Baud Rate | 9600 |
| Data Bits | 8 |
| Start Bits | 1 |
| Stop Bits | 1 |
| Parity | None |
| FIFO Data Width | 8 bits |
| FIFO Depth | 16 |

## Block Diagram

```text
                 +------------------+
                 |       FIFO       |
                 |   8-bit x 16     |
                 +--------+---------+
                          |
                          v
                 +------------------+
                 |  FSM Controller  |
                 +--------+---------+
                          |
                          v
                 +------------------+
                 |    UART TX       |
                 |   9600 Baud      |
                 +--------+---------+
                          |
                          | TX
                          v
                 +------------------+
                 |    UART RX       |
                 |   9600 Baud      |
                 +--------+---------+
                          |
                          v
                     RX Data