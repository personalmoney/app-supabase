import { Injectable } from '@angular/core';
import { SharedService } from '../core/services/shared.service';
import { SpinnerVisibilityService } from 'ng-http-loader';
import { SupabaseClient, createClient, User } from '@supabase/supabase-js';
import { environment } from 'src/environments/environment';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  public supabase: SupabaseClient;
  private _currentUser: BehaviorSubject<any> = new BehaviorSubject(null);

  constructor(
    private spinner: SpinnerVisibilityService,
    private shared: SharedService
  ) {
    this.supabase = createClient(environment.supabase.url, environment.supabase.key, {
      autoRefreshToken: true,
      persistSession: true
    });

    // Try to recover our user session
    this.loadUser();

    this.supabase.auth.onAuthStateChange((event, session) => {
      if (event == 'SIGNED_IN') {
        this._currentUser.next(session.user);
      } else {
        this._currentUser.next(false);
      }
    });
  }

  async loadUser() {
    const user = await this.supabase.auth.user();

    if (user) {
      this._currentUser.next(user);
    } else {
      this._currentUser.next(false);
    }
  }

  get currentUser(): Observable<User> {
    return this._currentUser.asObservable();
  }

  // Sign in with Google
  async googleLogin() {
    const value = await this.isLoggedIn();
    if (value === true) {
      return true;
    }
    this.spinner.show();
    await this.supabase.auth.signIn({ provider: 'google' }, { redirectTo: '/dashboard' });
    this.spinner.hide();
    this.shared.showMenu$.next(true);
  }

  async isLoggedIn(): Promise<boolean> {
    const currentUser = await this.supabase.auth.user();
    return currentUser != null;
  }

  async getUserName(): Promise<string> {
    const currentUser = await this.supabase.auth.user();
    if (currentUser == null) {
      return '';
    }
    return currentUser.email;
  }

  async signOut() {
    await this.supabase.auth.signOut();
  }

}
