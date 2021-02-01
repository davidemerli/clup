from . import ma
from flask import request, jsonify
from flask_restful import Resource
from flask_jwt_extended import get_jwt_identity, jwt_required
from .models import Store
from .schemas import StoreSchema
from marshmallow import fields, validate, ValidationError

MIN_RANGE_KM = 5.0
DEFAULT_RANGE_KM = 20.0
MAX_RANGE_KM = 150.0

class NearbyStores(Resource):

    class NearbyStoresRequestSchema(ma.Schema):
        latitude = fields.Float(required=True, validate=validate.Range(min=-90.0, max=90.0))
        longitude = fields.Float(required=True, validate=validate.Range(min=-180.0, max=180.0))
        radius_km = fields.Float(default=DEFAULT_RANGE_KM, missing=DEFAULT_RANGE_KM, validate=validate.Range(min=MIN_RANGE_KM, max=MAX_RANGE_KM))


    @jwt_required
    def post(self):
        request_schema = NearbyStores.NearbyStoresRequestSchema()
        try:
            content = request_schema.load(request.json)
        except ValidationError as err:
            return jsonify({
                'success': False,
                'errors': err.messages
            })
        query_results = Store.get_all_stores_radius((content['latitude'], content['longitude']), content['radius_km'] * 1000)
        results = StoreSchema().dump(query_results, many=True)
        return jsonify({
            'success': True,
            'stores': results
        })


