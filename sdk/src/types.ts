/**
 * Type definitions for Unichain SDK
 */

export interface UnichainConfig {
  apiKey?: string;
  network: 'mainnet' | 'testnet' | 'local';
  baseUrl?: string;
  timeout?: number;
}

export interface NetworkStatus {
  network: string;
  version: string;
  block_height: number;
  total_transactions: number;
  validators_count: number;
  total_stake: string;
  block_time: number;
  uptime: number;
  last_block_time: string;
}

export interface Block {
  height: number;
  hash: string;
  timestamp: string;
  transactions_count: number;
  validator: string;
  shard: string;
  workchain: number;
  gas_used: number;
  gas_limit: number;
  gas_price: number;
  total_fees: string;
  prev_block?: string;
  next_block?: string;
}

export interface Transaction {
  hash: string;
  block_height: number;
  timestamp: string;
  from: string;
  to: string;
  amount: string;
  fee: string;
  gas_used: number;
  gas_price: number;
  status: 'pending' | 'success' | 'failed';
  message?: string;
  data?: string;
  signature?: string;
}

export interface Account {
  address: string;
  balance: string;
  code_hash?: string;
  data_hash?: string;
  last_transaction_lt?: number;
  last_transaction_hash?: string;
  created_at: string;
  updated_at: string;
  is_contract: boolean;
  is_active: boolean;
}

export interface Contract {
  address: string;
  name: string;
  type: string;
  code_hash: string;
  data_hash: string;
  balance: string;
  created_at: string;
  methods: ContractMethod[];
  events: ContractEvent[];
}

export interface ContractMethod {
  name: string;
  signature: string;
  inputs: ContractParam[];
  outputs: ContractParam[];
}

export interface ContractEvent {
  name: string;
  signature: string;
  inputs: ContractParam[];
}

export interface ContractParam {
  name: string;
  type: string;
  indexed?: boolean;
}

export interface Validator {
  address: string;
  stake: string;
  commission: number;
  uptime: number;
  blocks_produced: number;
  last_block_time: string;
  is_active: boolean;
}

export interface SendTransactionRequest {
  from: string;
  to: string;
  amount: string;
  message?: string;
  data?: string;
  signature?: string;
}

export interface CallContractRequest {
  method: string;
  params: Record<string, any>;
  from: string;
  gas_limit?: number;
  gas_price?: number;
}

export interface ApiResponse<T> {
  status: 'success' | 'error';
  data?: T;
  error?: {
    code: number;
    message: string;
    details?: string;
  };
}

export interface WebSocketMessage {
  method: string;
  params?: any;
  id?: string;
  result?: any;
  error?: any;
}

export interface WebSocketSubscription {
  channel: string;
  address?: string;
  callback: (data: any) => void;
}
