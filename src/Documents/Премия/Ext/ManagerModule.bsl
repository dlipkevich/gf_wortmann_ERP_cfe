﻿
&После("ДобавитьКомандыПечати")
Процедура гф_ДобавитьКомандыПечати(КомандыПечати)
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Обработчик = "УправлениеПечатьюБЗККлиент.ВыполнитьКомандуПечати";
	КомандаПечати.Идентификатор = "ПФ_MXL_Т11а";
	КомандаПечати.Представление = НСтр("ru = 'Приказ о поощрении сотрудников (Т-11а) Мотив';
										|en = 'Employee recognition order (T-11a)'");
	КомандаПечати.МенеджерПечати = "Отчет.гф_ПечатнаяФормаТ11";
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Обработчик = "УправлениеПечатьюБЗККлиент.ВыполнитьКомандуПечати";
	КомандаПечати.Идентификатор = "ПФ_MXL_Т11";
	КомандаПечати.Представление = НСтр("ru = 'Приказы на каждого сотрудника в отдельности (Т-11) Мотив';
										|en = 'Orders for each employee individually (T-11)'");
	КомандаПечати.МенеджерПечати = "Отчет.гф_ПечатнаяФормаТ11";
	КомандаПечати.ДополнительныеПараметры.Вставить("РеквизитыДетализации", "РаботаСотрудник");
	
КонецПроцедуры

