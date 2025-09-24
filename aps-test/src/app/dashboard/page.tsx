/**
 * Page principale avec comptes + transactions - Dashboard professionnel compact
 */

"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { api } from '@/lib/api';
import { auth } from '@/lib/auth';
import { formatAccountType } from '@/lib/format';
import { AccountCard } from '@/components/AccountCard';
import { TransactionsList } from '@/components/TransactionsList';
import { TransferModal } from '@/components/TransferModal';
import { TransfersList } from '@/components/TransfersList';
import { Button } from '@/components/ui/button';
import { 
  LogOut, 
  Home, 
  CreditCard, 
  Activity, 
  Send, 
  Settings, 
  Bell, 
  Menu, 
  X, 
  User,
  TrendingUp,
  PlusCircle,
  Heart,
  MoreHorizontal,
  Search
} from 'lucide-react';
import { 
  AlertDialog, 
  AlertDialogAction, 
  AlertDialogCancel, 
  AlertDialogContent, 
  AlertDialogDescription, 
  AlertDialogFooter, 
  AlertDialogHeader, 
  AlertDialogTitle, 
  AlertDialogTrigger 
} from '@/components/ui/alert-dialog';

interface Account {
  id: string;
  type: string;
  currency: string;
  balance: number;
}

export default function Dashboard() {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedAccountId, setSelectedAccountId] = useState<string>('');
  const [showTransactions, setShowTransactions] = useState(false);
  const [showTransfers, setShowTransfers] = useState(false);
  const [showTransferModal, setShowTransferModal] = useState(false);
  const [transferFromAccount, setTransferFromAccount] = useState<Account | null>(null);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarExpanded, setSidebarExpanded] = useState(false);
  const router = useRouter();

  useEffect(() => {
    if (!auth.isAuthenticated()) {
      router.push('/login');
      return;
    }
    loadAccounts();
  }, [router]);

  const loadAccounts = async () => {
    try {
      const accountsData = await api.getAccounts();
      setAccounts(accountsData);
    } catch (error: any) {
      toast.error('Erreur lors du chargement des comptes');
      console.error('Error loading accounts:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleViewTransactions = (accountId: string) => {
    setSelectedAccountId(accountId);
    setShowTransactions(true);
    setShowTransfers(false); // Ensure transfers list is hidden
  };

  const handleTransfer = (account: Account) => {
    setTransferFromAccount(account);
    setShowTransferModal(true);
  };

  const handleLogout = () => {
    auth.logout();
  };

  const user = auth.getUser();

  const navigationItems = [
    { id: 'dashboard', label: 'Dashboard', icon: Home, active: !showTransactions && !showTransfers },
    { id: 'transactions', label: 'Transactions', icon: Activity, active: showTransactions },
    { id: 'transfers', label: 'Virements', icon: Send, active: showTransfers },
    { id: 'settings', label: 'Paramètres', icon: Settings, active: false },
  ];

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-gray-600">Chargement...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar - Extensible Professional Style */}
      <div className={`fixed inset-y-0 left-0 z-50 ${sidebarExpanded ? 'w-64' : 'w-16'} bg-white border-r border-gray-200 shadow-lg transform transition-all duration-300 ease-in-out lg:translate-x-0 ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} lg:static lg:inset-auto lg:transform-none`}>
        <div className="flex flex-col h-full py-6">
          {/* Logo & Toggle */}
          <div className="px-4 mb-8">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-sm">E</span>
                </div>
                {sidebarExpanded && (
                  <span className="font-semibold text-gray-900">Elliora Banking</span>
                )}
              </div>
              <button
                onClick={() => setSidebarExpanded(!sidebarExpanded)}
                className="hidden lg:flex w-8 h-8 items-center justify-center rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Menu className="w-4 h-4 text-gray-500" />
              </button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-3 space-y-2">
            {navigationItems.map((item, index) => {
              const Icon = item.icon;
              return (
                <button
                  key={item.id}
                  onClick={() => {
                    if (item.id === 'dashboard') {
                      setShowTransactions(false);
                      setShowTransfers(false);
                    } else if (item.id === 'transfers') {
                      setShowTransactions(false);
                      setShowTransfers(true);
                    } else if (item.id === 'transactions') {
                      // Pour afficher les transactions, on a besoin d'un compte sélectionné
                      if (accounts.length > 0) {
                        setSelectedAccountId(accounts[0].id);
                        setShowTransactions(true);
                        setShowTransfers(false);
                      }
                    }
                    setSidebarOpen(false);
                  }}
                  className={`w-full flex items-center space-x-3 px-3 py-3 rounded-xl transition-colors ${
                    item.active 
                      ? 'bg-primary text-white' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                  }`}
                  title={!sidebarExpanded ? item.label : undefined}
                >
                  <Icon className="w-5 h-5 flex-shrink-0" />
                  {sidebarExpanded && (
                    <span className="font-medium">{item.label}</span>
                  )}
                </button>
              );
            })}
          </nav>

          {/* User Profile */}
          <div className="px-4 mt-auto">
            <div className={`flex items-center space-x-3 p-3 rounded-xl hover:bg-gray-50 transition-colors ${sidebarExpanded ? '' : 'justify-center'}`}>
              <div className="w-8 h-8 rounded-full overflow-hidden flex-shrink-0">
                <img 
                  src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face" 
                  alt="Profile"
                  className="w-full h-full object-cover"
                />
              </div>
              {sidebarExpanded && (
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">{user?.name}</p>
                  <p className="text-xs text-gray-500 truncate">Utilisateur</p>
                </div>
              )}
              {sidebarExpanded && (
                <AlertDialog>
                  <AlertDialogTrigger asChild>
                    <button className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-gray-200 transition-colors">
                      <LogOut className="w-4 h-4 text-gray-500" />
                    </button>
                  </AlertDialogTrigger>
                  <AlertDialogContent className="max-w-md">
                    <AlertDialogHeader className="text-center">
                      <div className="mx-auto mb-4 w-16 h-16 rounded-3xl bg-red-500 flex items-center justify-center shadow-lg">
                        <LogOut className="w-8 h-8 text-white" />
                      </div>
                      <AlertDialogTitle className="text-xl font-semibold text-gray-900">
                        Confirmation de déconnexion
                      </AlertDialogTitle>
                      <AlertDialogDescription className="text-gray-600 mt-3">
                        Êtes-vous sûr de vouloir vous déconnecter ?
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter className="flex gap-3 mt-6">
                      <AlertDialogCancel className="flex-1 bg-gray-100 hover:bg-gray-200 border-0">
                        Annuler
                      </AlertDialogCancel>
                      <AlertDialogAction
                        onClick={handleLogout}
                        className="flex-1 bg-red-500 hover:bg-red-600 text-white border-0 shadow-lg"
                      >
                        Se déconnecter
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Overlay pour mobile */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 bg-black/20 backdrop-blur-sm z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Bar - Minimal Wise Style */}
        <header className="bg-white border-b border-gray-200 px-4 sm:px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setSidebarOpen(true)}
                className="lg:hidden w-10 h-10 rounded-xl"
              >
                <Menu className="w-5 h-5" />
              </Button>
              <div className="flex items-center space-x-3">
                <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-sm">E</span>
                </div>
                <span className="font-semibold text-gray-900">Elliora Banking</span>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <Button variant="ghost" size="sm" className="hidden sm:flex">
                <Bell className="w-4 h-4 mr-2" />
                Notifications
              </Button>
              <div className="w-8 h-8 rounded-full overflow-hidden">
                <img 
                  src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face" 
                  alt="Profile"
                  className="w-full h-full object-cover"
                />
              </div>
              <AlertDialog>
                <AlertDialogTrigger asChild>
                  <Button variant="ghost" size="sm">
                    <LogOut className="w-4 h-4" />
                  </Button>
                </AlertDialogTrigger>
                <AlertDialogContent className="max-w-md">
                  <AlertDialogHeader className="text-center">
                    <div className="mx-auto mb-4 w-16 h-16 rounded-3xl bg-red-500 flex items-center justify-center shadow-lg">
                      <LogOut className="w-8 h-8 text-white" />
                    </div>
                    <AlertDialogTitle className="text-xl font-semibold text-gray-900">
                      Confirmation de déconnexion
                    </AlertDialogTitle>
                    <AlertDialogDescription className="text-gray-600 mt-3">
                      Êtes-vous sûr de vouloir vous déconnecter ?
                    </AlertDialogDescription>
                  </AlertDialogHeader>
                  <AlertDialogFooter className="flex gap-3 mt-6">
                    <AlertDialogCancel className="flex-1 bg-gray-100 hover:bg-gray-200 border-0">
                      Annuler
                    </AlertDialogCancel>
                    <AlertDialogAction
                      onClick={handleLogout}
                      className="flex-1 bg-red-500 hover:bg-red-600 text-white border-0 shadow-lg"
                    >
                      Se déconnecter
                    </AlertDialogAction>
                  </AlertDialogFooter>
                </AlertDialogContent>
              </AlertDialog>
            </div>
          </div>
        </header>

        {/* Dashboard Content - SmartPay Style */}
        <main className="flex-1 p-6 overflow-auto">
          {!showTransactions && !showTransfers ? (
            <div className="space-y-6">
              {/* Welcome Header */}
              <div>
                <h1 className="text-2xl font-bold text-gray-900 mb-1">
                  Bienvenue, {user?.name} 👋
                </h1>
                <p className="text-gray-600">Voici un aperçu de vos finances</p>
              </div>

              {/* Stats Cards Row */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-white rounded-xl p-6 border border-gray-200">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-gray-600 text-sm mb-1">Solde Total</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {accounts.length > 0 ? 
                          `${(accounts.reduce((sum, acc) => sum + acc.balance, 0) / 1000).toFixed(0)} k FCFA` :
                          '0 FCFA'
                        }
                      </p>
                      <div className="flex items-center mt-2">
                        <span className="text-green-600 text-sm font-medium">↗ 25%</span>
                        <span className="text-gray-500 text-sm ml-1">vs last week</span>
                      </div>
                    </div>
                    <div className="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
                      <TrendingUp className="w-4 h-4 text-blue-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white rounded-xl p-6 border border-gray-200">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-gray-600 text-sm mb-1">Revenus Totaux</p>
                      <p className="text-2xl font-bold text-gray-900">
                        {accounts.length > 0 ? 
                          `${Math.round(accounts.reduce((sum, acc) => sum + acc.balance, 0) * 0.8 / 1000)} k FCFA` :
                          '0 FCFA'
                        }
                      </p>
                      <div className="flex items-center mt-2">
                        <span className="text-green-600 text-sm font-medium">↗ 15%</span>
                        <span className="text-gray-500 text-sm ml-1">vs last week</span>
                      </div>
                    </div>
                    <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
                      <TrendingUp className="w-4 h-4 text-green-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white rounded-xl p-6 border border-gray-200">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-gray-600 text-sm mb-1">Frais de Transaction</p>
                      <p className="text-2xl font-bold text-gray-900">75 FCFA</p>
                      <div className="flex items-center mt-2">
                        <span className="text-gray-500 text-sm">Aucun changement depuis la semaine dernière</span>
                      </div>
                    </div>
                    <div className="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center">
                      <Activity className="w-4 h-4 text-gray-600" />
                    </div>
                  </div>
                </div>
              </div>

              {/* Transaction History Section */}
              <div className="bg-white rounded-xl border border-gray-200 p-6">
                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-6 space-y-4 sm:space-y-0">
                  <h2 className="text-xl font-semibold text-gray-900">Historique des Transactions</h2>
                  <div className="flex flex-col sm:flex-row items-stretch sm:items-center space-y-2 sm:space-y-0 sm:space-x-3 w-full sm:w-auto">
                    <Button variant="outline" size="sm" className="text-gray-600 w-full sm:w-auto">
                      📄 Export File
                    </Button>
                    <Button 
                      onClick={() => accounts.length > 0 && handleTransfer(accounts[0])}
                      className="bg-primary hover:bg-primary-dark text-white w-full sm:w-auto"
                      size="sm"
                    >
                      + Nouveau Virement
                    </Button>
                  </div>
                </div>

                {/* Search and Filters */}
                <div className="flex flex-col sm:flex-row items-stretch sm:items-center space-y-3 sm:space-y-0 sm:space-x-4 mb-6">
                  <div className="relative flex-1 max-w-full sm:max-w-sm">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                    <input
                      type="text"
                      placeholder="Search"
                      className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    />
                  </div>
                  <Button variant="outline" size="sm" className="flex items-center justify-center space-x-2 w-full sm:w-auto">
                    <span>🔽</span>
                    <span>Filters</span>
                  </Button>
                </div>

                {/* Transactions Table */}
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-100">
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">
                          <input type="checkbox" className="rounded" />
                        </th>
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Bénéficiaire ↕</th>
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">N° Transaction ↕</th>
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Statut ↕</th>
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Date ↕</th>
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Heure ↕</th>
                        <th className="text-left py-3 px-4 text-sm font-medium text-gray-600">Description ↕</th>
                        <th className="text-right py-3 px-4 text-sm font-medium text-gray-600">Montant ↕</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-4 px-4">
                          <input type="checkbox" className="rounded" />
                        </td>
                        <td className="py-4 px-4 font-medium text-gray-900">Marie Dubois</td>
                        <td className="py-4 px-4 text-gray-600 font-mono text-sm">112397789298</td>
                        <td className="py-4 px-4">
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                            ● En attente
                          </span>
                        </td>
                        <td className="py-4 px-4 text-gray-600">11-23-2023</td>
                        <td className="py-4 px-4 text-gray-600">10:39PM</td>
                        <td className="py-4 px-4">
                          <a href="#" className="text-primary hover:underline">Facture #1083</a>
                        </td>
                        <td className="py-4 px-4 text-right font-semibold text-gray-900">1056 FCFA</td>
                      </tr>
                      <tr className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-4 px-4">
                          <input type="checkbox" className="rounded" />
                        </td>
                        <td className="py-4 px-4 font-medium text-gray-900">SoftServe Inc</td>
                        <td className="py-4 px-4 text-gray-600 font-mono text-sm">134239778923</td>
                        <td className="py-4 px-4">
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            ● Terminé
                          </span>
                        </td>
                        <td className="py-4 px-4 text-gray-600">11-22-2023</td>
                        <td className="py-4 px-4 text-gray-600">11:20AM</td>
                        <td className="py-4 px-4">
                          <a href="#" className="text-primary hover:underline">Facture #1390</a>
                        </td>
                        <td className="py-4 px-4 text-right font-semibold text-gray-900">1515 FCFA</td>
                      </tr>
                      <tr className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-4 px-4">
                          <input type="checkbox" className="rounded" />
                        </td>
                        <td className="py-4 px-4 font-medium text-gray-900">Maya LLC</td>
                        <td className="py-4 px-4 text-gray-600 font-mono text-sm">412495789238</td>
                        <td className="py-4 px-4">
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                            ● Refusé
                          </span>
                        </td>
                        <td className="py-4 px-4 text-gray-600">11-15-2023</td>
                        <td className="py-4 px-4 text-gray-600">13:08 PM</td>
                        <td className="py-4 px-4">
                          <a href="#" className="text-primary hover:underline">Facture #3468</a>
                        </td>
                        <td className="py-4 px-4 text-right font-semibold text-gray-900">2470 FCFA</td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                {/* Pagination */}
                <div className="flex flex-col sm:flex-row items-center justify-between mt-6 pt-4 border-t border-gray-100 space-y-4 sm:space-y-0">
                  <Button variant="outline" size="sm" className="flex items-center space-x-2 w-full sm:w-auto">
                    <span>←</span>
                    <span>Previous</span>
                  </Button>
                  <div className="flex items-center space-x-1 sm:space-x-2 order-first sm:order-none">
                    <Button variant="ghost" size="sm" className="w-8 h-8 p-0 bg-primary text-white">1</Button>
                    <Button variant="ghost" size="sm" className="w-8 h-8 p-0">2</Button>
                    <Button variant="ghost" size="sm" className="w-8 h-8 p-0">3</Button>
                    <span className="text-gray-400 hidden sm:inline">...</span>
                    <Button variant="ghost" size="sm" className="w-8 h-8 p-0 hidden sm:inline-flex">8</Button>
                    <Button variant="ghost" size="sm" className="w-8 h-8 p-0 hidden sm:inline-flex">9</Button>
                    <Button variant="ghost" size="sm" className="w-8 h-8 p-0">10</Button>
                  </div>
                  <Button variant="outline" size="sm" className="flex items-center space-x-2 w-full sm:w-auto">
                    <span>Next</span>
                    <span>→</span>
                  </Button>
                </div>
              </div>
            </div>
          ) : showTransactions ? (
            <TransactionsList
              accountId={selectedAccountId}
              onBack={() => setShowTransactions(false)}
            />
          ) : showTransfers ? (
            <TransfersList
              onBack={() => setShowTransfers(false)}
            />
          ) : null}
        </main>
      </div>

      {/* Transfer Modal */}
      {showTransferModal && transferFromAccount && (
        <TransferModal
          fromAccount={transferFromAccount}
          isOpen={showTransferModal}
          onClose={() => {
            setShowTransferModal(false);
            setTransferFromAccount(null);
          }}
          onSuccess={() => {
            setShowTransferModal(false);
            setTransferFromAccount(null);
            loadAccounts();
          }}
        />
      )}
    </div>
  );
}