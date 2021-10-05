//Copyright (c) 2021 Ultimaker B.V.
//Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.1
import Cura 1.1 as Cura
import UM 1.2 as UM

Window
{
    id: materialsSyncDialog
    property variant catalog: UM.I18nCatalog { name: "cura" }

    title: catalog.i18nc("@title:window", "Sync materials with printers")
    minimumWidth: UM.Theme.getSize("modal_window_minimum").width
    minimumHeight: UM.Theme.getSize("modal_window_minimum").height
    width: minimumWidth
    height: minimumHeight
    modality: Qt.ApplicationModal

    property alias pageIndex: swipeView.currentIndex

    SwipeView
    {
        id: swipeView
        anchors.fill: parent
        interactive: false

        Rectangle
        {
            id: introPage
            color: UM.Theme.getColor("main_background")
            Column
            {
                spacing: UM.Theme.getSize("default_margin").height
                anchors.fill: parent
                anchors.margins: UM.Theme.getSize("default_margin").width

                Label
                {
                    text: catalog.i18nc("@title:header", "Sync materials with printers")
                    font: UM.Theme.getFont("large_bold")
                    color: UM.Theme.getColor("text")
                }
                Label
                {
                    text: catalog.i18nc("@text", "Following a few simple steps, you will be able to synchronize all your material profiles with your printers.")
                    font: UM.Theme.getFont("medium")
                    color: UM.Theme.getColor("text")
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
                Image
                {
                    source: UM.Theme.getImage("material_ecosystem")
                    width: parent.width
                    sourceSize.width: width
                }
            }

            Cura.PrimaryButton
            {
                id: startButton
                anchors
                {
                    right: parent.right
                    rightMargin: UM.Theme.getSize("default_margin").width
                    bottom: parent.bottom
                    bottomMargin: UM.Theme.getSize("default_margin").height
                }
                text: catalog.i18nc("@button", "Start")
                onClicked: {
                    if(Cura.API.account.isLoggedIn)
                    {
                        swipeView.currentIndex += 2; //Skip sign in page.
                    }
                    else
                    {
                        swipeView.currentIndex += 1;
                    }
                }
            }
            Cura.TertiaryButton
            {
                anchors
                {
                    left: parent.left
                    leftMargin: UM.Theme.getSize("default_margin").width
                    verticalCenter: startButton.verticalCenter
                }
                text: catalog.i18nc("@button", "Why do I need to sync material profiles?")
                iconSource: UM.Theme.getIcon("LinkExternal")
                isIconOnRightSide: true
                onClicked: Qt.openUrlExternally("https://ultimaker.com")
            }
        }

        Rectangle
        {
            id: signinPage
            color: UM.Theme.getColor("main_background")

            Connections //While this page is active, continue to the next page if the user logs in.
            {
                target: Cura.API.account
                function onLoginStateChanged(is_logged_in)
                {
                    if(is_logged_in && signinPage.SwipeView.isCurrentItem)
                    {
                        swipeView.currentIndex += 1;
                    }
                }
            }

            ColumnLayout
            {
                spacing: UM.Theme.getSize("default_margin").height
                anchors.fill: parent
                anchors.margins: UM.Theme.getSize("default_margin").width

                Label
                {
                    text: catalog.i18nc("@title:header", "Sign in")
                    font: UM.Theme.getFont("large_bold")
                    color: UM.Theme.getColor("text")
                    Layout.preferredHeight: height
                }
                Label
                {
                    text: catalog.i18nc("@text", "To automatically sync the material profiles with all your printers connected to Digital Factory you need to be signed in in Cura.")
                    font: UM.Theme.getFont("medium")
                    color: UM.Theme.getColor("text")
                    wrapMode: Text.WordWrap
                    width: parent.width
                    Layout.maximumWidth: width
                    Layout.preferredHeight: height
                }
                Item
                {
                    Layout.preferredWidth: parent.width
                    Layout.fillHeight: true
                    Image
                    {
                        source: UM.Theme.getImage("first_run_ultimaker_cloud")
                        width: parent.width / 2
                        sourceSize.width: width
                        anchors.centerIn: parent
                    }
                }
                Item
                {
                    width: parent.width
                    height: childrenRect.height
                    Layout.preferredHeight: height
                    Cura.SecondaryButton
                    {
                        anchors.left: parent.left
                        text: catalog.i18nc("@button", "Sync materials with USB")
                        onClicked: swipeView.currentIndex = swipeView.count - 1 //Go to the last page, which is USB.
                    }
                    Cura.PrimaryButton
                    {
                        anchors.right: parent.right
                        text: catalog.i18nc("@button", "Sign in")
                        onClicked: Cura.API.account.login()
                    }
                }
            }
        }

        Rectangle
        {
            id: printerListPage
            color: UM.Theme.getColor("main_background")

            ColumnLayout
            {
                spacing: UM.Theme.getSize("default_margin").height
                anchors.fill: parent
                anchors.margins: UM.Theme.getSize("default_margin").width

                Label
                {
                    text: catalog.i18nc("@title:header", "The following printers will receive the new material profiles")
                    font: UM.Theme.getFont("large_bold")
                    color: UM.Theme.getColor("text")
                    Layout.preferredHeight: height
                }
                ScrollView
                {
                    id: printerListScrollView
                    width: parent.width
                    Layout.preferredWidth: width
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ListView
                    {
                        id: printerList
                        width: parent.width
                        spacing: UM.Theme.getSize("default_margin").height

                        model: Cura.GlobalStacksModel {}
                        delegate: Rectangle
                        {
                            border.color: UM.Theme.getColor("lining")
                            border.width: UM.Theme.getSize("default_lining").width
                            width: printerListScrollView.width
                            height: UM.Theme.getSize("card").height

                            Cura.IconWithText
                            {
                                anchors
                                {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: Math.round(parent.height - height) / 2 //Equal margin on the left as above and below.
                                    right: parent.right
                                    rightMargin: Math.round(parent.height - height) / 2
                                }

                                text: model.name
                                font: UM.Theme.getFont("medium")

                                source: UM.Theme.getIcon("Printer", "medium")
                                iconColor: UM.Theme.getColor("machine_selector_printer_icon")
                                iconSize: UM.Theme.getSize("machine_selector_icon").width

                                //Printer status badge (always cloud, but whether it's online or offline).
                                UM.RecolorImage
                                {
                                    width: UM.Theme.getSize("printer_status_icon").width
                                    height: UM.Theme.getSize("printer_status_icon").height
                                    anchors
                                    {
                                        bottom: parent.bottom
                                        bottomMargin: -Math.round(height / 6)
                                        left: parent.left
                                        leftMargin: parent.iconSize - Math.round(width * 5 / 6)
                                    }

                                    source: UM.Theme.getIcon("CloudBadge", "low")
                                    color: "red" //TODO: connectionStatus == "printer_cloud_not_available" ? UM.Theme.getColor("cloud_unavailable") : UM.Theme.getColor("primary")

                                    //Make a themeable circle in the background so we can change it in other themes.
                                    Rectangle
                                    {
                                        anchors.centerIn: parent
                                        width: parent.width - 1.5 //1.5 pixels smaller (at least sqrt(2), regardless of pixel scale) so that the circle doesn't show up behind the icon due to anti-aliasing.
                                        height: parent.height - 1.5
                                        radius: width / 2
                                        color: UM.Theme.getColor("connection_badge_background")
                                        z: parent.z - 1
                                    }
                                }
                            }
                        }

                        footer: Item
                        {
                            width: printerListScrollView.width
                            height: UM.Theme.getSize("card").height + UM.Theme.getSize("default_margin").height
                            Rectangle
                            {
                                border.color: UM.Theme.getColor("lining")
                                border.width: UM.Theme.getSize("default_lining").width
                                anchors.fill: parent
                                anchors.topMargin: UM.Theme.getSize("default_margin").height

                                RowLayout
                                {
                                    anchors
                                    {
                                        fill: parent
                                        leftMargin: (parent.height - infoIcon.height) / 2 //Same margin on the left as top and bottom.
                                        rightMargin: (parent.height - infoIcon.height) / 2
                                    }
                                    spacing: UM.Theme.getSize("default_margin").width

                                    Rectangle //Info icon with a themeable color and background.
                                    {
                                        id: infoIcon
                                        width: UM.Theme.getSize("machine_selector_icon").width
                                        height: width
                                        Layout.preferredWidth: width
                                        Layout.alignment: Qt.AlignVCenter
                                        radius: height / 2
                                        color: UM.Theme.getColor("warning")

                                        UM.RecolorImage
                                        {
                                            source: UM.Theme.getIcon("EmptyInfo")
                                            anchors.fill: parent
                                            color: UM.Theme.getColor("machine_selector_printer_icon")
                                        }
                                    }

                                    Label
                                    {
                                        text: catalog.i18nc("@text Asking the user whether printers are missing in a list.", "Printers missing?")
                                          + "\n"
                                          + catalog.i18nc("@text", "Make sure all your printers are turned ON and connected to Digital Factory.")
                                        font: UM.Theme.getFont("medium")
                                        elide: Text.ElideRight

                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.fillWidth: true
                                    }

                                    Cura.SecondaryButton
                                    {
                                        id: refreshListButton
                                        text: catalog.i18nc("@button", "Refresh List")
                                        iconSource: UM.Theme.getIcon("ArrowDoubleCircleRight")

                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: width
                                    }
                                }
                            }
                        }
                    }
                }
                Cura.TertiaryButton
                {
                    text: catalog.i18nc("@button", "Troubleshooting")
                    iconSource: UM.Theme.getIcon("LinkExternal")
                    Layout.preferredHeight: height
                }
                Item
                {
                    width: parent.width
                    height: childrenRect.height
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    Cura.SecondaryButton
                    {
                        anchors.left: parent.left
                        text: catalog.i18nc("@button", "Sync materials with USB")
                        onClicked: swipeView.currentIndex = swipeView.count - 1 //Go to the last page, which is USB.
                    }
                    Cura.PrimaryButton
                    {
                        anchors.right: parent.right
                        text: catalog.i18nc("@button", "Sync")
                    }
                }
            }
        }
    }
}