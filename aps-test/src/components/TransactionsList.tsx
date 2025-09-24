/**
 * Liste des transactions avec filtres/pagination - Conforme au cahier des charges,
 * pour etre conforme avec le test
 */

"use client";

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { toast } from 'sonner';
import { api } from '@/lib/api';
import { formatCurrency, formatDate } from '@/lib/format';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { 
  ArrowLeft, 
  Search, 
  ArrowUpDown, 
  ChevronLeft, 
  ChevronRight,
  ArrowUp,
  ArrowDown 
} from 'lucide-react';

interface Transaction {
  id: string;
  date: string;
  amount: number;
  currency: string;
  description: string;
  status: string;
}

interface TransactionsListProps {
  accountId: string;
  onBack: () => void;
}

export function TransactionsList({ accountId, onBack }: TransactionsListProps) {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [sortBy, setSortBy] = useState('date');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [total, setTotal] = useState(0);
  const pageSize = 10;

  useEffect(() => {
    loadTransactions();
  }, [accountId, currentPage, search, sortBy, sortOrder]);

  const loadTransactions = async () => {
    setIsLoading(true);
    try {
      const response = await api.getTransactions(accountId, {
        page: currentPage,
        pageSize,
        search,
        sortBy,
        sortOrder,
      });
      
      setTransactions(response.items);
      setTotalPages(response.totalPages);
      setTotal(response.total);
    } catch (error: any) {
      toast.error('Erreur lors du chargement des transactions');
      console.error('Error loading transactions:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSearch = (value: string) => {
    setSearch(value);
    setCurrentPage(1);
  };

  const handleSort = (field: string) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortOrder('desc');
    }
    setCurrentPage(1);
  };

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const getTransactionIcon = (amount: number) => {
    return amount >= 0 ? (
      <ArrowUp className="w-4 h-4 text-green-600" />
    ) : (
      <ArrowDown className="w-4 h-4 text-red-600" />
    );
  };

  const getTransactionColor = (amount: number) => {
    return amount >= 0 ? 'text-green-600' : 'text-red-600';
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Button
            variant="outline"
            onClick={onBack}
            className="flex items-center space-x-2"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Retour</span>
          </Button>
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Transactions</h2>
            <p className="text-gray-600">Compte {accountId}</p>
          </div>
        </div>
      </div>

      {/* Filtres et recherche */}
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6">
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Recherche */}
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              type="text"
              placeholder="Rechercher par description, ID transaction..."
              value={search}
              onChange={(e) => handleSearch(e.target.value)}
              className="pl-10 h-11 border-gray-200 focus:border-primary focus:ring-primary"
            />
          </div>

          {/* Tri */}
          <div className="flex items-center space-x-3">
            <Select value={sortBy} onValueChange={setSortBy}>
              <SelectTrigger className="w-40 h-11 border-gray-200 focus:border-primary focus:ring-primary">
                <SelectValue placeholder="Trier par" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="date">Date</SelectItem>
                <SelectItem value="amount">Montant</SelectItem>
                <SelectItem value="description">Description</SelectItem>
              </SelectContent>
            </Select>
            
            <Button
              variant="outline"
              onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
              className="h-11 px-4 border-gray-200 hover:border-gray-300"
            >
              <ArrowUpDown className="w-4 h-4 mr-2" />
              <span className="hidden sm:inline">{sortOrder === 'asc' ? 'Croissant' : 'Décroissant'}</span>
              <span className="sm:hidden">{sortOrder === 'asc' ? 'Asc' : 'Desc'}</span>
            </Button>
          </div>
        </div>
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">Historique des transactions</h3>
            <Badge variant="secondary" className="bg-primary/10 text-primary">
              {total} transaction{total > 1 ? 's' : ''}
            </Badge>
          </div>
        </div>
        
        {isLoading ? (
          <div className="flex items-center justify-center py-16">
            <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
            <span className="ml-3 text-gray-600">Chargement des transactions...</span>
          </div>
        ) : transactions.length === 0 ? (
          <div className="text-center py-16">
            <div className="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
              <Search className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune transaction trouvée</h3>
            <p className="text-gray-500 max-w-sm mx-auto">
              Essayez de modifier vos critères de recherche ou filtres pour voir plus de résultats.
            </p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-gray-50/50 hover:bg-gray-50/50">
                <TableHead className="w-12"></TableHead>
                <TableHead className="font-semibold text-gray-900">Transaction</TableHead>
                <TableHead className="font-semibold text-gray-900">Date & Heure</TableHead>
                <TableHead className="font-semibold text-gray-900">Statut</TableHead>
                <TableHead className="font-semibold text-gray-900 text-right">Montant</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <AnimatePresence>
                {transactions.map((transaction, index) => (
                  <motion.tr
                    key={transaction.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.3, delay: index * 0.05 }}
                    className="group hover:bg-gray-50/50 transition-colors border-b border-gray-100 last:border-b-0"
                  >
                    <TableCell className="py-4">
                      <div className="flex items-center justify-center">
                        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${
                          transaction.amount >= 0 
                            ? 'bg-green-100' 
                            : 'bg-red-100'
                        }`}>
                          {getTransactionIcon(transaction.amount)}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="py-4">
                      <div>
                        <p className="font-semibold text-gray-900 mb-1">
                          {transaction.description}
                        </p>
                        <p className="text-sm text-gray-500 font-mono">
                          ID: {transaction.id}
                        </p>
                      </div>
                    </TableCell>
                    <TableCell className="py-4">
                      <div className="text-sm">
                        <p className="text-gray-900 font-medium">
                          {new Date(transaction.date).toLocaleDateString('fr-FR', {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric'
                          })}
                        </p>
                        <p className="text-gray-500">
                          {new Date(transaction.date).toLocaleTimeString('fr-FR', {
                            hour: '2-digit',
                            minute: '2-digit'
                          })}
                        </p>
                      </div>
                    </TableCell>
                    <TableCell className="py-4">
                      <Badge 
                        variant="secondary"
                        className={`text-xs font-medium ${
                          transaction.status === 'posted' 
                            ? 'bg-green-100 text-green-800 border-green-200' 
                            : 'bg-yellow-100 text-yellow-800 border-yellow-200'
                        }`}
                      >
                        {transaction.status === 'posted' ? 'Validée' : 'En attente'}
                      </Badge>
                    </TableCell>
                    <TableCell className="py-4 text-right">
                      <div className="flex flex-col items-end">
                        <p className={`text-lg font-bold ${getTransactionColor(transaction.amount)}`}>
                          {transaction.amount >= 0 ? '+' : ''}{formatCurrency(transaction.amount, transaction.currency)}
                        </p>
                        <p className="text-xs text-gray-500 mt-1">
                          {transaction.currency}
                        </p>
                      </div>
                    </TableCell>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </TableBody>
          </Table>
        )}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-gray-600">
            Page {currentPage} sur {totalPages}
          </p>
          
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => handlePageChange(currentPage - 1)}
              disabled={currentPage === 1}
            >
              <ChevronLeft className="w-4 h-4" />
            </Button>
            
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const page = Math.max(1, Math.min(totalPages - 4, currentPage - 2)) + i;
              return (
                <Button
                  key={page}
                  variant={currentPage === page ? "default" : "outline"}
                  size="sm"
                  onClick={() => handlePageChange(page)}
                  className="w-8 h-8 p-0"
                >
                  {page}
                </Button>
              );
            })}
            
            <Button
              variant="outline"
              size="sm"
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
            >
              <ChevronRight className="w-4 h-4" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}