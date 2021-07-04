import { Injectable } from '@angular/core';
import { SyncService } from 'src/app/core/services/sync.service';
import { Category } from '../models/category';
import { HttpClient } from '@angular/common/http';
import { SqLiteService } from 'src/app/core/services/sq-lite.service';
import { Observable, from } from 'rxjs';
import { SharedService } from 'src/app/core/services/shared.service';
import { SubCategory } from '../models/sub-category';
import { map, switchMap } from 'rxjs/operators';
import { AuthService } from 'src/app/services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class CategoryService extends SyncService<Category> {
  endpoint = 'categories';
  tableName = 'Category';

  constructor(
    http: HttpClient,
    protected shared: SharedService,
    authService: AuthService,
    sqlite: SqLiteService
  ) {
    super(http, shared, authService, sqlite);
  }

  async getAll() {
    if (this.shared.isWeb) {
      return await super.getAll(false, `*,sub_categories(id,name,category_id)`);
    }
    const data = await super.getAll();

    const query = `SELECT S.localId,S.localUpdatedTime,S.id,S.name,S.localCategoryId,S.createdTime,S.updatedTime,C.id as categoryId
          FROM SubCategory S
          INNER JOIN Category C ON S.localCategoryId=C.localId WHERE S.isDeleted='${this.shared.falseValue}'`;
    const result = await this.sqlite.query(query);
    const values = result.values as SubCategory[];
    data.forEach(d => {
      d.sub_categories = values.filter(f => f.local_category_id === d.local_id);
    });
    return data;
  }

  createLocalParms(record: Category): Observable<Category> {
    const query = `INSERT INTO ${this.tableName}(name,id,createdTime,updatedTime,isDeleted,localUpdatedTime) Values(?,?,?,?,?,?)`;
    const values = [record.name, record.id, new Date(), record.updated_time, false, record.local_updated_time];
    return super.createLocal(record, query, values);
  }

  updateLocalParms(record: Category) {
    const query = `UPDATE ${this.tableName} SET name=?,updatedTime=?,localUpdatedTime=? WHERE localId=?`;
    const values = [record.name, record.updated_time, record.local_updated_time, record.local_id];
    return super.updateLocal(record, query, values);
  }
}
