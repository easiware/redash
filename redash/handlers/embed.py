from flask import make_response, request
from flask_login import current_user, login_required
from flask_restful import abort

from redash import models, settings
from redash.handlers import routes
from redash.handlers.base import (
    get_object_or_404,
    org_scoped_rule,
    record_event,
)
from redash.handlers.query_results import (
    ONE_YEAR,
    content_disposition_filenames,
    get_download_filename,
)
from redash.handlers.static import render_index
from redash.security import csp_allows_embeding
from redash.serializers.query_result import (
    serialize_query_result_to_dsv,
    serialize_query_result_to_xlsx,
)

from .authentication import current_org


@routes.route(
    org_scoped_rule("/embed/query/<query_id>/visualization/<visualization_id>"),
    methods=["GET"],
)
@login_required
@csp_allows_embeding
def embed(query_id, visualization_id, org_slug=None):
    record_event(
        current_org,
        current_user._get_current_object(),
        {
            "action": "view",
            "object_id": visualization_id,
            "object_type": "visualization",
            "query_id": query_id,
            "embed": True,
            "referer": request.headers.get("Referer"),
        },
    )
    return render_index()


@routes.route(org_scoped_rule("/public/dashboards/<token>"), methods=["GET"])
@login_required
@csp_allows_embeding
def public_dashboard(token, org_slug=None):
    if current_user.is_api_user():
        dashboard = current_user.object
    else:
        api_key = get_object_or_404(models.ApiKey.get_by_api_key, token)
        dashboard = api_key.object

    record_event(
        current_org,
        current_user,
        {
            "action": "view",
            "object_id": dashboard.id,
            "object_type": "dashboard",
            "public": True,
            "headless": "embed" in request.args,
            "referer": request.headers.get("Referer"),
        },
    )
    return render_index()


# Autorise le téléchargement de csv via un dashboard public.
# Basé sur redash/handlers/query_results.py.
@routes.route(
    org_scoped_rule(
        "/public/<token>/queries/<query_id>/results/<result_id>.<filetype>"
    ),
    methods=["GET"],
)
@login_required
@csp_allows_embeding
def query_results(token, query_id, result_id, filetype, org_slug=None):
    api_key = get_object_or_404(models.ApiKey.get_by_api_key, token)

    dashboard = api_key.object

    has_access = any(
        w.visualization.query_rel.id == int(query_id) for w in dashboard.widgets
    )

    if not has_access:
        abort(403)

    query_result = get_object_or_404(
        models.QueryResult.get_by_id_and_org, result_id, current_org
    )

    query = get_object_or_404(models.Query.get_by_id_and_org, query_id, current_org)

    response = None

    if filetype == "csv":
        headers = {"Content-Type": "text/csv; charset=UTF-8"}
        response = make_response(
            serialize_query_result_to_dsv(query_result, ","), 200, headers
        )
    elif filetype == "tsv":
        headers = {"Content-Type": "text/tab-separated-values; charset=UTF-8"}
        response = make_response(
            serialize_query_result_to_dsv(query_result, "\t"), 200, headers
        )
    elif filetype == "xlsx":
        headers = {
            "Content-Type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        }
        response = make_response(
            serialize_query_result_to_xlsx(query_result), 200, headers
        )
    else:
        abort(400, message="Wrong filetype.")

    if len(settings.ACCESS_CONTROL_ALLOW_ORIGIN) > 0:
        if "Origin" in request.headers:
            origin = request.headers["Origin"]

            if set(["*", origin]) & settings.ACCESS_CONTROL_ALLOW_ORIGIN:
                response.headers["Access-Control-Allow-Origin"] = origin
                response.headers["Access-Control-Allow-Credentials"] = str(
                    settings.ACCESS_CONTROL_ALLOW_CREDENTIALS
                ).lower()

    response.headers.add_header("Cache-Control", "private,max-age=%d" % ONE_YEAR)

    filename = get_download_filename(query_result, query, filetype)
    filenames = content_disposition_filenames(filename)

    response.headers.add("Content-Disposition", "attachment", **filenames)

    return response
