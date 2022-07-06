﻿
// #wortmann {
// #4.2.03
// Создание группы досупа и её установка в партнере 
// Галфинд Окунев 2022/07/05
&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ)
	
	Если Ссылка.Пустая() И ЗначениеЗаполнено(Партнер) Тогда
		
		Если Не ЗначениеЗаполнено(Партнер.ГруппаДоступа) Тогда
		
			ГруппаДоступа = Справочники.ГруппыДоступаПартнеров.СоздатьЭлемент();
		
			ГруппаДоступа.Наименование = СокрЛП(Партнер.Наименование)+" "+СокрЛП(Партнер.Код);
			
			ГруппаДоступа.Записать();
			
			ПартнерОбъект = Партнер.ПолучитьОбъект();
			
			ПартнерОбъект.ГруппаДоступа = ГруппаДоступа.Ссылка;  
			
			ПартнерОбъект.ОбменДанными.Загрузка = Истина;
			
			ПартнерОбъект.Записать();
		
		КонецЕсли;
		
	КонецЕсли;	
	
КонецПроцедуры// } #wortmann
