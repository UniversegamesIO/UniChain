/**
 * Unichain Client
 * Main client for interacting with Unichain blockchain
 */

import axios, { AxiosInstance, AxiosResponse } from 'axios';
import WebSocket from 'ws';
import {
  UnichainConfig,
  NetworkStatus,
  Block,
  Transaction,
  Account,
  Contract,
  Validator,
  SendTransactionRequest,
  CallContractRequest,
  ApiResponse,
  WebSocketMessage,
  WebSocketSubscription
} from './types';

export class UnichainClient {
  private config: UnichainConfig;
  private httpClient: AxiosInstance;
  private wsClient?: WebSocket;
  private subscriptions: Map<string, WebSocketSubscription> = new Map();

  constructor(config: UnichainConfig) {
    this.config = {
      timeout: 30000,
      ...config
    };

    // Set base URL based on network
    if (!this.config.baseUrl) {
      switch (this.config.network) {
        case 'mainnet':
          this.config.baseUrl = 'https://api.unichain.org';
          break;
        case 'testnet':
          this.config.baseUrl = 'https://testnet-api.unichain.org';
          break;
        case 'local':
          this.config.baseUrl = 'http://localhost:8080';
          break;
      }
    }

    // Initialize HTTP client
    this.httpClient = axios.create({
      baseURL: this.config.baseUrl,
      timeout: this.config.timeout,
      headers: {
        'Content-Type': 'application/json',
        ...(this.config.apiKey && { Authorization: `Bearer ${this.config.apiKey}` })
      }
    });

    // Add response interceptor
    this.httpClient.interceptors.response.use(
      (response: AxiosResponse) => response,
      (error) => {
        if (error.response?.data?.error) {
          throw new Error(error.response.data.error.message);
        }
        throw error;
      }
    );
  }

  /**
   * Get network status
   */
  async getStatus(): Promise<NetworkStatus> {
    const response = await this.httpClient.get<ApiResponse<NetworkStatus>>('/v1/status');
    return response.data.data!;
  }

  /**
   * Get block by height
   */
  async getBlock(height: number): Promise<Block> {
    const response = await this.httpClient.get<ApiResponse<Block>>(`/v1/blocks/${height}`);
    return response.data.data!;
  }

  /**
   * Get latest blocks
   */
  async getLatestBlocks(limit: number = 10): Promise<Block[]> {
    const response = await this.httpClient.get<ApiResponse<{ blocks: Block[] }>>(`/v1/blocks/latest?limit=${limit}`);
    return response.data.data!.blocks;
  }

  /**
   * Get transaction by hash
   */
  async getTransaction(hash: string): Promise<Transaction> {
    const response = await this.httpClient.get<ApiResponse<Transaction>>(`/v1/transactions/${hash}`);
    return response.data.data!;
  }

  /**
   * Send transaction
   */
  async sendTransaction(tx: SendTransactionRequest): Promise<{ hash: string; status: string }> {
    const response = await this.httpClient.post<ApiResponse<{ hash: string; status: string }>>('/v1/transactions/send', tx);
    return response.data.data!;
  }

  /**
   * Get account information
   */
  async getAccount(address: string): Promise<Account> {
    const response = await this.httpClient.get<ApiResponse<Account>>(`/v1/accounts/${address}`);
    return response.data.data!;
  }

  /**
   * Get account balance
   */
  async getBalance(address: string): Promise<{ balance: string; currency: string; decimals: number }> {
    const response = await this.httpClient.get<ApiResponse<{ balance: string; currency: string; decimals: number }>>(`/v1/accounts/${address}/balance`);
    return response.data.data!;
  }

  /**
   * Get account transactions
   */
  async getAccountTransactions(address: string, limit: number = 20, offset: number = 0): Promise<Transaction[]> {
    const response = await this.httpClient.get<ApiResponse<{ transactions: Transaction[] }>>(
      `/v1/accounts/${address}/transactions?limit=${limit}&offset=${offset}`
    );
    return response.data.data!.transactions;
  }

  /**
   * Get contract information
   */
  async getContract(address: string): Promise<Contract> {
    const response = await this.httpClient.get<ApiResponse<Contract>>(`/v1/contracts/${address}`);
    return response.data.data!;
  }

  /**
   * Call contract method
   */
  async callContract(address: string, call: CallContractRequest): Promise<{ transaction_hash: string; gas_used: number; result: any }> {
    const response = await this.httpClient.post<ApiResponse<{ transaction_hash: string; gas_used: number; result: any }>>(`/v1/contracts/${address}/call`, call);
    return response.data.data!;
  }

  /**
   * Get validators list
   */
  async getValidators(): Promise<Validator[]> {
    const response = await this.httpClient.get<ApiResponse<{ validators: Validator[] }>>('/v1/validators');
    return response.data.data!.validators;
  }

  /**
   * Get validator statistics
   */
  async getValidatorStats(address: string): Promise<any> {
    const response = await this.httpClient.get<ApiResponse<any>>(`/v1/validators/${address}/stats`);
    return response.data.data!;
  }

  /**
   * Search by hash
   */
  async searchByHash(hash: string): Promise<{ type: string; hash: string; block_height: number; timestamp: string }> {
    const response = await this.httpClient.get<ApiResponse<{ type: string; hash: string; block_height: number; timestamp: string }>>(`/v1/search/${hash}`);
    return response.data.data!;
  }

  /**
   * Search accounts
   */
  async searchAccounts(query: string, limit: number = 10): Promise<Account[]> {
    const response = await this.httpClient.get<ApiResponse<{ accounts: Account[] }>>(`/v1/search/accounts?q=${query}&limit=${limit}`);
    return response.data.data!.accounts;
  }

  /**
   * Connect to WebSocket
   */
  connectWebSocket(): Promise<void> {
    return new Promise((resolve, reject) => {
      const wsUrl = this.config.baseUrl!.replace('http', 'ws').replace('https', 'wss') + '/v1/ws';
      
      this.wsClient = new WebSocket(wsUrl);

      this.wsClient.on('open', () => {
        console.log('Connected to Unichain WebSocket API');
        resolve();
      });

      this.wsClient.on('message', (data: WebSocket.Data) => {
        try {
          const message: WebSocketMessage = JSON.parse(data.toString());
          this.handleWebSocketMessage(message);
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      });

      this.wsClient.on('error', (error) => {
        console.error('WebSocket error:', error);
        reject(error);
      });

      this.wsClient.on('close', () => {
        console.log('Disconnected from Unichain WebSocket API');
      });
    });
  }

  /**
   * Subscribe to WebSocket channel
   */
  subscribe(channel: string, callback: (data: any) => void, address?: string): void {
    if (!this.wsClient) {
      throw new Error('WebSocket not connected. Call connectWebSocket() first.');
    }

    const subscription: WebSocketSubscription = { channel, address, callback };
    const key = address ? `${channel}:${address}` : channel;
    this.subscriptions.set(key, subscription);

    const message: WebSocketMessage = {
      method: 'subscribe',
      params: { channel, ...(address && { address }) }
    };

    this.wsClient.send(JSON.stringify(message));
  }

  /**
   * Unsubscribe from WebSocket channel
   */
  unsubscribe(channel: string, address?: string): void {
    if (!this.wsClient) {
      return;
    }

    const key = address ? `${channel}:${address}` : channel;
    this.subscriptions.delete(key);

    const message: WebSocketMessage = {
      method: 'unsubscribe',
      params: { channel, ...(address && { address }) }
    };

    this.wsClient.send(JSON.stringify(message));
  }

  /**
   * Disconnect WebSocket
   */
  disconnectWebSocket(): void {
    if (this.wsClient) {
      this.wsClient.close();
      this.wsClient = undefined;
      this.subscriptions.clear();
    }
  }

  /**
   * Handle WebSocket messages
   */
  private handleWebSocketMessage(message: WebSocketMessage): void {
    if (message.result) {
      // Handle subscription confirmation
      return;
    }

    if (message.error) {
      console.error('WebSocket error:', message.error);
      return;
    }

    // Handle data messages
    const { channel, address } = message.params || {};
    const key = address ? `${channel}:${address}` : channel;
    const subscription = this.subscriptions.get(key);

    if (subscription) {
      subscription.callback(message.result || message);
    }
  }

  /**
   * Get client configuration
   */
  getConfig(): UnichainConfig {
    return { ...this.config };
  }
}
