import { useEffect, useState } from "react";
import axios from "axios";
import { useAuth } from "@/hooks/use-auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import {
  UserPlus,
  Shield,
  Trash2,
  Key,
  Mail,
  User,
  Loader2,
  Eye,
  EyeOff,
  AlertCircle
} from "lucide-react";

type UserType = {
  id: string;
  email?: string;
  firstName?: string;
  lastName?: string;
  role?: string;
};

export function AdminManagement() {
  const { user: currentUser } = useAuth();
  const { toast } = useToast();
  const [users, setUsers] = useState<UserType[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Registration form state
  const [email, setEmail] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Change password dialog state
  const [isChangePwdOpen, setIsChangePwdOpen] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [changePwdValue, setChangePwdValue] = useState("");
  const [changePwdConfirmValue, setChangePwdConfirmValue] = useState("");
  const [changePwdVisible, setChangePwdVisible] = useState(false);
  const [changePwdSubmitting, setChangePwdSubmitting] = useState(false);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const res = await axios.get("/api/admin/users", { withCredentials: true });
      // Filter only administrators
      const admins = (res.data || []).filter((u: UserType) => u.role === "admin");
      setUsers(admins);
    } catch (err: any) {
      toast({
        title: "Erro ao buscar administradores",
        description: err.response?.data?.message || "Ocorreu um erro ao carregar os dados.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) {
      toast({ title: "Campo obrigatório", description: "O e-mail é obrigatório.", variant: "destructive" });
      return;
    }
    if (password && password !== confirmPassword) {
      toast({ title: "Erro de validação", description: "As senhas não conferem.", variant: "destructive" });
      return;
    }

    try {
      setSubmitting(true);
      await axios.post(
        "/api/admin/users",
        {
          email,
          firstName,
          lastName,
          role: "admin",
          password: password || undefined,
        },
        { withCredentials: true }
      );
      toast({
        title: "Sucesso!",
        description: "Novo administrador cadastrado com sucesso.",
      });
      // Clear form
      setEmail("");
      setFirstName("");
      setLastName("");
      setPassword("");
      setConfirmPassword("");
      setPasswordVisible(false);
      fetchUsers();
    } catch (err: any) {
      toast({
        title: "Falha ao cadastrar",
        description: err.response?.data?.message || "Não foi possível cadastrar o administrador.",
        variant: "destructive",
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string, nameOrEmail: string) => {
    if (!confirm(`Deseja realmente remover o administrador ${nameOrEmail}?`)) return;

    try {
      await axios.delete(`/api/admin/users/${id}`, { withCredentials: true });
      toast({
        title: "Sucesso!",
        description: "Administrador removido com sucesso.",
      });
      fetchUsers();
    } catch (err: any) {
      toast({
        title: "Erro ao remover",
        description: err.response?.data?.message || "Não foi possível remover o administrador.",
        variant: "destructive",
      });
    }
  };

  const handleChangePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedUserId) return;
    if (!changePwdValue) {
      toast({ title: "Campo obrigatório", description: "A nova senha é obrigatória.", variant: "destructive" });
      return;
    }
    if (changePwdValue !== changePwdConfirmValue) {
      toast({ title: "Erro de validação", description: "As senhas não conferem.", variant: "destructive" });
      return;
    }

    try {
      setChangePwdSubmitting(true);
      await axios.put(
        `/api/admin/users/${selectedUserId}`,
        { password: changePwdValue },
        { withCredentials: true }
      );
      toast({
        title: "Sucesso!",
        description: "Senha alterada com sucesso.",
      });
      setIsChangePwdOpen(false);
      setSelectedUserId(null);
      setChangePwdValue("");
      setChangePwdConfirmValue("");
      setChangePwdVisible(false);
    } catch (err: any) {
      toast({
        title: "Erro ao alterar senha",
        description: err.response?.data?.message || "Não foi possível alterar a senha.",
        variant: "destructive",
      });
    } finally {
      setChangePwdSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Registration Form Card */}
        <Card className="flex-1">
          <CardHeader>
            <CardTitle className="text-xl flex items-center gap-2">
              <UserPlus className="h-5 w-5 text-primary" />
              Novo Administrador
            </CardTitle>
            <CardDescription>
              Cadastre uma nova credencial administrativa no sistema.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <form onSubmit={handleRegister} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="email">E-mail</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="email@exemplo.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-9"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="firstName">Nome</Label>
                  <div className="relative">
                    <User className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      id="firstName"
                      placeholder="Nome"
                      value={firstName}
                      onChange={(e) => setFirstName(e.target.value)}
                      className="pl-9"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="lastName">Sobrenome</Label>
                  <Input
                    id="lastName"
                    placeholder="Sobrenome"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">Senha</Label>
                <div className="relative">
                  <Key className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="password"
                    type={passwordVisible ? "text" : "password"}
                    placeholder="Defina uma senha"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="pl-9 pr-9"
                  />
                  <button
                    type="button"
                    className="absolute right-3 top-2.5 text-muted-foreground hover:text-foreground"
                    onClick={() => setPasswordVisible(!passwordVisible)}
                  >
                    {passwordVisible ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirmar Senha</Label>
                <div className="relative">
                  <Key className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="confirmPassword"
                    type={passwordVisible ? "text" : "password"}
                    placeholder="Repita a senha"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="pl-9"
                  />
                </div>
              </div>

              <Button type="submit" className="w-full" disabled={submitting}>
                {submitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Cadastrando...
                  </>
                ) : (
                  "Cadastrar Administrador"
                )}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Admins List Card */}
        <Card className="flex-[1.5]">
          <CardHeader>
            <CardTitle className="text-xl flex items-center gap-2">
              <Shield className="h-5 w-5 text-primary" />
              Administradores Atuais
            </CardTitle>
            <CardDescription>
              Lista de usuários com privilégios administrativos no sistema.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="flex items-center justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
              </div>
            ) : users.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                Nenhum administrador cadastrado.
              </div>
            ) : (
              <div className="border rounded-md overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Nome</TableHead>
                      <TableHead>E-mail</TableHead>
                      <TableHead className="text-right">Ações</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {users.map((u) => {
                      const name = [u.firstName, u.lastName].filter(Boolean).join(" ") || "Sem nome";
                      const isSelf = u.id === currentUser?.id;
                      return (
                        <TableRow key={u.id} className={isSelf ? "bg-slate-50/55" : ""}>
                          <TableCell className="font-medium flex items-center gap-2">
                            {name}
                            {isSelf && (
                              <span className="text-[10px] bg-primary/10 text-primary px-1.5 py-0.5 rounded font-normal">
                                Você
                              </span>
                            )}
                          </TableCell>
                          <TableCell>{u.email}</TableCell>
                          <TableCell className="text-right">
                            <div className="flex justify-end gap-2">
                              <Button
                                variant="outline"
                                size="icon"
                                className="h-8 w-8 text-amber-500 border-amber-200 hover:bg-amber-50 hover:text-amber-600"
                                onClick={() => {
                                  setSelectedUserId(u.id);
                                  setIsChangePwdOpen(true);
                                }}
                                title="Alterar Senha"
                              >
                                <Key className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="outline"
                                size="icon"
                                className="h-8 w-8 text-destructive border-destructive/20 hover:bg-destructive/10"
                                onClick={() => handleDelete(u.id, u.email || name)}
                                disabled={isSelf}
                                title={isSelf ? "Você não pode se excluir" : "Remover Administrador"}
                              >
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            </div>
                          </TableCell>
                        </TableRow>
                      );
                    })}
                  </TableBody>
                </Table>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Change Password Dialog */}
      <Dialog open={isChangePwdOpen} onOpenChange={(open) => {
        if (!open) {
          setSelectedUserId(null);
          setChangePwdValue("");
          setChangePwdConfirmValue("");
          setChangePwdVisible(false);
        }
        setIsChangePwdOpen(open);
      }}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Alterar Senha</DialogTitle>
            <DialogDescription>
              Defina uma nova senha para o administrador selecionado.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleChangePasswordSubmit} className="space-y-4 pt-2">
            <div className="space-y-2">
              <Label htmlFor="changePwd">Nova Senha</Label>
              <div className="relative">
                <Key className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  id="changePwd"
                  type={changePwdVisible ? "text" : "password"}
                  placeholder="Nova senha"
                  value={changePwdValue}
                  onChange={(e) => setChangePwdValue(e.target.value)}
                  className="pl-9 pr-9"
                  required
                />
                <button
                  type="button"
                  className="absolute right-3 top-2.5 text-muted-foreground hover:text-foreground"
                  onClick={() => setChangePwdVisible(!changePwdVisible)}
                >
                  {changePwdVisible ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="changePwdConfirm">Confirmar Nova Senha</Label>
              <div className="relative">
                <Key className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  id="changePwdConfirm"
                  type={changePwdVisible ? "text" : "password"}
                  placeholder="Confirme a nova senha"
                  value={changePwdConfirmValue}
                  onChange={(e) => setChangePwdConfirmValue(e.target.value)}
                  className="pl-9"
                  required
                />
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsChangePwdOpen(false)}
              >
                Cancelar
              </Button>
              <Button type="submit" disabled={changePwdSubmitting}>
                {changePwdSubmitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Salvando...
                  </>
                ) : (
                  "Alterar Senha"
                )}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
