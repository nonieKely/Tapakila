import { CreateParams, CreateResult, DataProvider, DeleteManyParams, DeleteManyResult, DeleteParams, DeleteResult, GetListParams, GetListResult, GetManyParams, GetManyReferenceParams, GetManyReferenceResult, GetManyResult, GetOneParams, GetOneResult, Identifier, QueryFunctionContext, RaRecord, UpdateManyParams, UpdateManyResult, UpdateParams, UpdateResult } from "react-admin";
import userDataProvider from "./user/user-dataProvider";

const resourceDataProvider = {
    user: userDataProvider
}

const mydataProvider:DataProvider ={
    getList: function <RecordType extends RaRecord = any>(resource: string, params: GetListParams & QueryFunctionContext): Promise<GetListResult<RecordType>> {
        return resourceDataProvider["user"]?.getList() || Promise.reject(new Error(`Resource ${resource} not found`));
    },
    getOne: function <RecordType extends RaRecord = any>(resource: string, params: GetOneParams<RecordType> & QueryFunctionContext): Promise<GetOneResult<RecordType>> {
        throw new Error("Function not implemented.");
    },
    getMany: function <RecordType extends RaRecord = any>(resource: string, params: GetManyParams<RecordType> & QueryFunctionContext): Promise<GetManyResult<RecordType>> {
        throw new Error("Function not implemented.");
    },
    getManyReference: function <RecordType extends RaRecord = any>(resource: string, params: GetManyReferenceParams & QueryFunctionContext): Promise<GetManyReferenceResult<RecordType>> {
        throw new Error("Function not implemented.");
    },
    update: function <RecordType extends RaRecord = any>(resource: string, params: UpdateParams): Promise<UpdateResult<RecordType>> {
        throw new Error("Function not implemented.");
    },
    updateMany: function <RecordType extends RaRecord = any>(resource: string, params: UpdateManyParams): Promise<UpdateManyResult<RecordType>> {
        throw new Error("Function not implemented.");
    },
    create: function <RecordType extends Omit<RaRecord, "id"> = any, ResultRecordType extends RaRecord = RecordType & { id: Identifier; }>(resource: string, params: CreateParams): Promise<CreateResult<ResultRecordType>> {
        throw new Error("Function not implemented.");
    },
    delete: function <RecordType extends RaRecord = any>(resource: string, params: DeleteParams<RecordType>): Promise<DeleteResult<RecordType>> {
        throw new Error("Function not implemented.");
    },
    deleteMany: function <RecordType extends RaRecord = any>(resource: string, params: DeleteManyParams<RecordType>): Promise<DeleteManyResult<RecordType>> {
        throw new Error("Function not implemented.");
    }
}

export default mydataProvider;