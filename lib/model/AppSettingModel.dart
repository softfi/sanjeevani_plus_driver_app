// To parse this JSON data, do
//
//     final appSettingModel = appSettingModelFromJson(jsonString);

import 'dart:convert';

AppSettingModel appSettingModelFromJson(String str) => AppSettingModel.fromJson(json.decode(str));

String appSettingModelToJson(AppSettingModel data) => json.encode(data.toJson());

class AppSettingModel {
    Region? region;
    AppSeeting? appSeeting;
    PrivacyPolicy? termsCondition;
    PrivacyPolicy? privacyPolicy;
    List<PrivacyPolicy>? rideSetting;
    List<dynamic>? walletSetting;
    int? rideForOther;
    CurrencySetting? currencySetting;

    AppSettingModel({
        this.region,
        this.appSeeting,
        this.termsCondition,
        this.privacyPolicy,
        this.rideSetting,
        this.walletSetting,
        this.rideForOther,
        this.currencySetting,
    });

    factory AppSettingModel.fromJson(Map<String, dynamic> json) => AppSettingModel(
        region: json["region"] == null ? null : Region.fromJson(json["region"]),
        appSeeting: json["app_seeting"] == null ? null : AppSeeting.fromJson(json["app_seeting"]),
        termsCondition: json["terms_condition"] == null ? null : PrivacyPolicy.fromJson(json["terms_condition"]),
        privacyPolicy: json["privacy_policy"] == null ? null : PrivacyPolicy.fromJson(json["privacy_policy"]),
        rideSetting: json["ride_setting"] == null ? [] : List<PrivacyPolicy>.from(json["ride_setting"]!.map((x) => PrivacyPolicy.fromJson(x))),
        walletSetting: json["Wallet_setting"] == null ? [] : List<dynamic>.from(json["Wallet_setting"]!.map((x) => x)),
        rideForOther: json["ride_for_other"],
        currencySetting: json["currency_setting"] == null ? null : CurrencySetting.fromJson(json["currency_setting"]),
    );

    Map<String, dynamic> toJson() => {
        "region": region?.toJson(),
        "app_seeting": appSeeting?.toJson(),
        "terms_condition": termsCondition?.toJson(),
        "privacy_policy": privacyPolicy?.toJson(),
        "ride_setting": rideSetting == null ? [] : List<dynamic>.from(rideSetting!.map((x) => x.toJson())),
        "Wallet_setting": walletSetting == null ? [] : List<dynamic>.from(walletSetting!.map((x) => x)),
        "ride_for_other": rideForOther,
        "currency_setting": currencySetting?.toJson(),
    };
}

class AppSeeting {
    int? id;
    String? siteName;
    dynamic siteEmail;
    String? siteLogo;
    String? siteFavicon;
    String? siteDarkLogo;
    String? siteDescription;
    dynamic siteCopyright;
    String? facebookUrl;
    String? instagramUrl;
    String? twitterUrl;
    dynamic linkedinUrl;
    List<String?>? languageOption;
    dynamic contactEmail;
    dynamic contactNumber;
    dynamic helpSupportUrl;
    List<dynamic>? notificationSettings;
    dynamic createdAt;
    dynamic updatedAt;

    AppSeeting({
        this.id,
        this.siteName,
        this.siteEmail,
        this.siteLogo,
        this.siteFavicon,
        this.siteDarkLogo,
        this.siteDescription,
        this.siteCopyright,
        this.facebookUrl,
        this.instagramUrl,
        this.twitterUrl,
        this.linkedinUrl,
        this.languageOption,
        this.contactEmail,
        this.contactNumber,
        this.helpSupportUrl,
        this.notificationSettings,
        this.createdAt,
        this.updatedAt,
    });

    factory AppSeeting.fromJson(Map<String, dynamic> json) => AppSeeting(
        id: json["id"],
        siteName: json["site_name"],
        siteEmail: json["site_email"],
        siteLogo: json["site_logo"],
        siteFavicon: json["site_favicon"],
        siteDarkLogo: json["site_dark_logo"],
        siteDescription: json["site_description"],
        siteCopyright: json["site_copyright"],
        facebookUrl: json["facebook_url"],
        instagramUrl: json["instagram_url"],
        twitterUrl: json["twitter_url"],
        linkedinUrl: json["linkedin_url"],
        languageOption: json["language_option"] == null ? [] : List<String?>.from(json["language_option"]!.map((x) => x)),
        contactEmail: json["contact_email"],
        contactNumber: json["contact_number"],
        helpSupportUrl: json["help_support_url"],
        notificationSettings: json["notification_settings"] == null ? [] : List<dynamic>.from(json["notification_settings"]!.map((x) => x)),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "site_name": siteName,
        "site_email": siteEmail,
        "site_logo": siteLogo,
        "site_favicon": siteFavicon,
        "site_dark_logo": siteDarkLogo,
        "site_description": siteDescription,
        "site_copyright": siteCopyright,
        "facebook_url": facebookUrl,
        "instagram_url": instagramUrl,
        "twitter_url": twitterUrl,
        "linkedin_url": linkedinUrl,
        "language_option": languageOption == null ? [] : List<dynamic>.from(languageOption!.map((x) => x)),
        "contact_email": contactEmail,
        "contact_number": contactNumber,
        "help_support_url": helpSupportUrl,
        "notification_settings": notificationSettings == null ? [] : List<dynamic>.from(notificationSettings!.map((x) => x)),
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}

class CurrencySetting {
    String? name;
    String? symbol;
    String? code;
    String? position;

    CurrencySetting({
        this.name,
        this.symbol,
        this.code,
        this.position,
    });

    factory CurrencySetting.fromJson(Map<String, dynamic> json) => CurrencySetting(
        name: json["name"],
        symbol: json["symbol"],
        code: json["code"],
        position: json["position"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "symbol": symbol,
        "code": code,
        "position": position,
    };
}

class PrivacyPolicy {
    int? id;
    String? key;
    String? type;
    String? value;

    PrivacyPolicy({
        this.id,
        this.key,
        this.type,
        this.value,
    });

    factory PrivacyPolicy.fromJson(Map<String, dynamic> json) => PrivacyPolicy(
        id: json["id"],
        key: json["key"],
        type: json["type"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "type": type,
        "value": value,
    };
}

class Region {
    int? id;
    String? name;
    String? distanceUnit;
    int? status;
    String? timezone;
    DateTime? createdAt;
    DateTime? updatedAt;

    Region({
        this.id,
        this.name,
        this.distanceUnit,
        this.status,
        this.timezone,
        this.createdAt,
        this.updatedAt,
    });

    factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json["id"],
        name: json["name"],
        distanceUnit: json["distance_unit"],
        status: json["status"],
        timezone: json["timezone"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "distance_unit": distanceUnit,
        "status": status,
        "timezone": timezone,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
