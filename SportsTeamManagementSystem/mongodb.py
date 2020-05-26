import pymongo
from bson import ObjectId
import datetime as dt

ENTRY_FEE = 2500
# connect the database server
connection = pymongo.MongoClient('localhost', 27017)
# create/select the database
database = connection['SportsEventManagement']
# create/choose the collection
collection = database['Teams']


# function to insert data
def insert_team(teams):
    collection.insert_one(teams)


# function to delete data
def delete_team(row_id):
    document = collection.delete_one({'_id': ObjectId(row_id)})
    return document.acknowledged


# function to fetch data
def get_team_data(team):
    fee_status = False
    if team._entry_fee == 'Paid':
        fee_status = True

    if team._name != '' and team._city == '' and team._total_players == '' and team._entry_fee != '':
        data = collection.find(
            {
                "name": {"$regex": team._name, "$options": 'i'},
                "entry_fee": fee_status}
        )
    elif team._city != '' and team._name == '' and team._total_players == '' and team._entry_fee != '':
        data = collection.find(
            {
                "city": {"$regex": team._city, "$options": 'i'},
                "entry_fee": fee_status
            }
        )
    elif team._total_players != '' and team._name == '' and team._city == '' and team._entry_fee != '':
        data = collection.find(
            {
                "total_players": team._total_players,
                "entry_fee": fee_status
            }
        )
    elif team._name != '' and team._city != '' and team._total_players == '' and team._entry_fee != '':
        data = collection.find(
            {
                "name": {"$regex": team._name, "$options": 'i'},
                "city": {"$regex": team._city, "$options": 'i'},
                "entry_fee": fee_status
            }
        )
    elif team._total_players != '' and team._city != '' and team._name == '' and team._entry_fee != '':
        data = collection.find(
            {
                "total_players": team._total_players,
                "city": {"$regex": team._city, "$options": 'i'},
                "entry_fee": fee_status
            }
        )
    elif team._total_players != '' and team._name != '' and team._entry_fee != '':
        data = collection.find(
            {
                "total_players": team._total_players,
                "name": {"$regex": team._name, "$options": 'i'},
                "entry_fee": fee_status
            }
        )
    elif team._entry_fee != '' and team._city == '' and team._total_players == '' and team._name == '':
        data = collection.find(
            {"entry_fee": fee_status}
        )
    elif team._entry_fee != '' and team._city != '' and team._total_players != '' and team._name != '':
        data = collection.find(
            {
                "name": {"$regex": team._name, "$options": 'i'},
                "city": {"$regex": team._city, "$options": 'i'},
                "total_players": team._total_players,
                "entry_fee": {"$regex": fee_status}
            }
        )
    else:
        data = collection.find()

    return list(data)


# function to update data
def update_team_data(data, row_id):
    document = collection.update_one({'_id': ObjectId(row_id)}, {"$set": data})
    return document.acknowledged


def show_summary():
    return_list = []
    total_teams = collection.find().count()
    return_list.append(total_teams)

    total_teams_paid = collection.find({"entry_fee": True}).count()
    total_fees_gained = int(total_teams_paid) * ENTRY_FEE
    return_list.append(total_fees_gained)

    unpaid_teams_percent = ((int(total_teams) - int(total_teams_paid)) / int(total_teams)) * 100
    return_list.append(round(unpaid_teams_percent, 2))

    return return_list


def get_team_registration_data():
    data = collection.aggregate( [ { "$project": { "name": 1, "registered_date": 1, "dateDifference": { "$subtract": ["$$NOW", "$registered_date"]}}}] )

    return list(data)
